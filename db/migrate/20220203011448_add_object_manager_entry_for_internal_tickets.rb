class AddObjectManagerEntryForInternalTickets < ActiveRecord::Migration[6.0]
  def change
  ObjectManager::Attribute.add(
    force:       true,
    object:      'Ticket',
    name:        'internal',
    display:     __('Internal'),
    data_type:   'boolean',
    data_option: {
      default: false,
      options: {
        true: "yes",
        false: "no"
      },
      nulloption: true,
      multiple:   false,
      null:       true,
      translate:  true,
    },
    editable:    false,
    active:      true,
    screens:     {
      "create_middle" => {
        "ticket.agent"=> { 
          "shown" => false, 
          "required" => false, 
          "item_class" => "column"
        }, 
        "ticket.customer" => {
          "shown" => false, 
          "required" => false, 
          "item_class" => "column"
        }
      }, 
      "edit" => {
        "ticket.agent" => {
          "shown" => true, 
          "required" => false
        }, 
        "ticket.customer" => {
          "shown" => false, 
          "required" => false
        }
      }
    },
  to_create:   false,
  to_migrate:  false,
  to_delete:   false,
  position:    90,
  updated_by_id: 1,
  created_by_id: 1,
  )
  end
end
