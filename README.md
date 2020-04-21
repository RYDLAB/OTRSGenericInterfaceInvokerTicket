# OTRS GenericInterface Invoker Ticket

This is invoker for ticket events.

# Accepts

*  TicketID

# Returns

* Ticket
    
        TicketNumber       => '20101027000001',
        Title              => 'some title',
        TicketID           => 123,
        State              => 'some state',
        StateID            => 123,
        StateType          => 'some state type',
        Priority           => 'some priority',
        PriorityID         => 123,
        Lock               => 'lock',
        LockID             => 123,
        Queue              => 'some queue',
        QueueID            => 123,
        CustomerID         => 'customer_id_123',
        CustomerUserID     => 'customer_user_id_123',
        Owner              => 'some_owner_login',
        OwnerID            => 123,
        Type               => 'some ticket type',
        TypeID             => 123,
        SLA                => 'some sla',
        SLAID              => 123,
        Service            => 'some service',
        ServiceID          => 123,
        Responsible        => 'some_responsible_login',
        ResponsibleID      => 123,
        Age                => 3456,
        Created            => '2010-10-27 20:15:00'
        CreateBy           => 123,
        Changed            => '2010-10-27 20:15:15',
        ChangeBy           => 123,
        ArchiveFlag        => 'y',
        DynamicField_X     => 'value_x',

        


* Article

        TicketID             => 123,
        ArticleID            => 123,
        From                 => 'Some Agent <email@example.com>',
        To                   => 'Some Customer A <customer-a@example.com>',
        Cc                   => 'Some Customer B <customer-b@example.com>',
        Bcc                  => 'Some Customer C <customer-c@example.com>',
        ReplyTo              => 'Some Customer B <customer-b@example.com>',
        Subject              => 'some short description',
        MessageID            => '<asdasdasd.123@example.com>',
        InReplyTo            => '<asdasdasd.12@example.com>',
        References           => '<asdasdasd.1@example.com> <asdasdasd.12@example.com>',
        ContentType          => 'text/plain; charset=ISO-8859-15',
        Body                 => 'the message text',
        SenderTypeID         => 1,
        SenderType           => 'agent',
        IsVisibleForCustomer => 1,
        IncomingTime         => 1490690026,
        CreateBy             => 1,
        CreateTime           => '2017-03-28 08:33:47',
        Charset              => 'ISO-8859-15',
        MimeType             => 'text/plain',

# From response accept

* TicketID and put it into configurable dynamic field (e.g. JiraIssueID). Check config for invoker

# Invoker config
`GenericInterface::Invoker::Ticket::TicketUpdate::Settings`

Here you can add pair webserviceID => dynamic field for TicketID(response)