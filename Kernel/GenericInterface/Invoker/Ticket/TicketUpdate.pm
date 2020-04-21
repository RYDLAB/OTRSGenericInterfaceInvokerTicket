# --
# Copyright (C) 2001-2020 OTRS AG, https://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package Kernel::GenericInterface::Invoker::Ticket::TicketUpdate;

use strict;
use warnings;

use Kernel::System::VariableCheck qw( IsStringWithData IsHashRefWithData );

# prevent 'Used once' warning for Kernel::OM
use Kernel::System::ObjectManager;

our $ObjectManagerDisabled = 1;

our @ObjectDependencies = (
    'Kernel::System::Ticket',
    'Kernel::System::Ticket::Article',
    'Kernel::Config',
);

sub new {
    my ( $Type, %Param ) = @_;

    my $Self = {};
    bless( $Self, $Type );

    for my $Required (qw{ DebuggerObject WebserviceID }) {
        if ( !$Param{ $Required } ) {
            return {
                Success      => 0,
                ErrorMessage => "Got no $Required",
            };
        }

        $Self->{ $Required } = $Param{ $Required };
    }

    return $Self;
}

sub PrepareRequest {
    my ( $Self, %Param ) = @_;

    if (!IsStringWithData( $Param{Data}{TicketID} ) && !IsStringWithData( $Param{TicketID} )) {
        return $Self->{DebuggerObject}->Error( Summary => 'Got no TicketNumber' );
    }

    $Self->{TicketID} = $Param{TicketID} || $Param{Data}{TicketID};

    my $TicketObject       = $Kernel::OM->Get('Kernel::System::Ticket');
    my $ArticleObject      = $Kernel::OM->Get('Kernel::System::Ticket::Article');
    my $DynamicFieldObject = $Kernel::OM->Get('Kernel::System::DynamicField');

    my %Ticket = $TicketObject->TicketGet(
        TicketID      => $Self->{TicketID},
        DynamicFields => 1,
    );

    $Self->{ChangeBy} = $Ticket{ChangeBy};

    my ($MetaArticle) = $ArticleObject->ArticleList(
        TicketID => $Self->{TicketID},
        OnlyLast => 1,
    );

    my %Article = $ArticleObject->BackendForArticle( %$MetaArticle )->ArticleGet( %$MetaArticle );

    return {
        Success => 1,
        Data    => {
            Ticket  => \%Ticket,
            Article => \%Article,
        },
    };
}

sub HandleResponse {
    my ( $Self, %Param ) = @_;

    if (!$Param{Data}{TicketID}) {
        return $Self->{DebuggerObject}->Error( Summary => 'Got no TicketID' );
    }

    my $TicketObject            = $Kernel::OM->Get('Kernel::System::Ticket');
    my $ConfigObject            = $Kernel::OM->Get('Kernel::Config');
    my $DynamicFieldObject      = $Kernel::OM->Get('Kernel::System::DynamicField');
    my $DynamicFieldValueObject = $Kernel::OM->Get('Kernel::System::DynamicFieldValue');

    my $Settings = $ConfigObject->Get('GenericInterface::Invoker::Ticket::TicketUpdate::Settings');

    if (!$Settings) {
        return $Self->{DebuggerObject}->Error( Summary => 'Can not load config' );
    }

    my ($Setting) = grep { $_->{WebserviceID} eq $Self->{WebserviceID } } @$Settings;

    if (!$Setting) {
        return $Self->{DebuggerObject}->Error( Summary => "Can not locate setting with WebserviceID $Self->{WebserviceID}" );
    }

    my $DynamicFieldName = $Setting->{DynamicFieldName};

    my $DynamicField = $DynamicFieldObject->DynamicFieldGet(
        Name => $DynamicFieldName,
    );

    if (!IsHashRefWithData($DynamicField)) {
        my $ID = $DynamicFieldObject->DynamicFieldAdd(
            Name       => $DynamicFieldName,
            Config     => {
                DefaultValue => '',
                RegExList    => [],
                Link         => '',
                LinkPreview  => '',
            },
            Label      => $DynamicFieldName,
            FieldOrder => 999,
            FieldType  => 'Text',
            ObjectType => 'Ticket',
            UserID     => $Self->{ChangeBy},
            ValidID    => 1,
        );

        if (!$ID) {
            return $Self->{DebuggerObject}->Error(
                Summary => "Can not add dynamic field with name $DynamicFieldName",
            );
        }

        $DynamicField = $DynamicFieldObject->DynamicFieldGet(
            ID => $ID,
        );
    }

    my $Success = $DynamicFieldValueObject->ValueSet(
        ObjectID    => $Self->{TicketID},
        FieldID     => $DynamicField->{ID},
        Value       => [{
            ValueText => $Param{Data}{TicketID},
        }],
        UserID      => $Self->{ChangeBy},
    );

    if ($Success) {
        return { Success => 1 };
    }

    return $Self->{DebuggerObject}->Error(
        Summary =>
            "Can not set dynamic field $DynamicField->{ID} with value $Param{Data}{TicketID}
             for ticket with ID $Self->{TicketID}",
    );
}

1
