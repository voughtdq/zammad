# Copyright (C) 2012-2022 Zammad Foundation, https://zammad-foundation.org/

class AddInternalOptionToTicketCreateXTypeSetting < ActiveRecord::Migration[6.0]
  def change
    # return if it's a new setup
    return if !Setting.exists?(name: 'system_init_done')

    default_type = Setting.find_by(name: 'ui_ticket_create_default_type')
    default_type.options = {
      form: [
        {
          display:  '',
          null:     false,
          multiple: false,
          name:     'ui_ticket_create_default_type',
          tag:      'select',
          options:  {
            'phone-in'  => '1. Phone inbound',
            'phone-out' => '2. Phone outbound',
            'email-out' => '3. Email outbound',
            'internal'  => '4. Internal',
          },
        },
      ],
    }
    default_type.save!

    available_types = Setting.find_by(name: 'ui_ticket_create_available_types')
    available_types.options = {
      form: [
        {
          display:  '',
          null:     false,
          multiple: true,
          name:     'ui_ticket_create_available_types',
          tag:      'select',
          options:  {
            'phone-in'  => '1. Phone inbound',
            'phone-out' => '2. Phone outbound',
            'email-out' => '3. Email outbound',
            'internal'  => '4. Internal',
          },
        },
      ],
    }
    available_types.state = %w[phone-in phone-out email-out internal]
    available_types.save!
  end
end
