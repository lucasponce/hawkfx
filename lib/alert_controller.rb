require 'hawkular/hawkular_client'

require_relative 'alert_list_cell_factory'
require_relative 'alert_list_item'
require_relative 'hawk'
require_relative 'time_picker'

class AlertController
  include JRubyFX::Controller
  fxml 'fxalerts.fxml'

  def initialize
    box = find '#alertEventTopBox'
    box.children.add time_picker(self, :update_time_range)

    @FXMLalertList.cell_factory = proc { ::AlertListCellFactory.new }

    @insert_tab.children.add event_insert_controller



    display_items
  end

  # Callback from Alert/Event toggle
  def switch_alert_event
    # TODO: clean out selected item details
    display_items
  end

  def selected_tab_has_changed
    display_items
  end

  # Callback from time picker
  def update_time_range(time_in_ms)
    @start_offset = time_in_ms
    display_items
  end

  private

  def display_items
    return if @start_offset.nil?

    start = Time.now.to_i * 1000 - @start_offset
    alerts_selected = @FXMLAlertEventSelector.selected

    if alerts_selected
      alerts = Hawk.alerts.list_alerts 'startTime' => start
    else
      alerts = Hawk.alerts.list_events 'startTime' => start
    end

    the_list = observable_array_list []
    alerts.each do |alert|
      item = AlertListItem.new
      item.alert = alert
      the_list.add item
    end
    @FXMLalertList.items = the_list
  end
end
