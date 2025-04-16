# config/initializers/event_subscribers.rb
Rails.application.config.after_initialize do
  return if Rails.env.test? || !defined?(::Kafka)
  
  begin
    kafka_config = Rails.application.credentials.kafka
    
    subscriber = DataBridgeShared::Clients::EventSubscriber.new(
      seed_brokers: kafka_config[:brokers],
      client_id: kafka_config[:client_id],
      consumer_group: kafka_config[:consumer_group]
    )
    
    require Rails.root.join('app/events/subscribers/customer_updated_event_handler')
    require Rails.root.join('app/events/subscribers/product_updated_event_handler')
    require Rails.root.join('app/events/subscribers/inventory_changed_event_handler')
    
    # Register event handlers
    subscriber.subscribe('CustomerUpdated', ::Events::Subscribers::CustomerUpdatedEventHandler.new)
    subscriber.subscribe('ProductUpdated', ::Events::Subscribers::ProductUpdatedEventHandler.new)
    subscriber.subscribe('InventoryChanged', ::Events::Subscribers::InventoryChangedEventHandler.new)
    
    Rails.logger.info "Order Service event subscribers registered successfully"
  rescue => e
    Rails.logger.error "Failed to register event subscribers: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
  end
end