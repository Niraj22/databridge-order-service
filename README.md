# DataBridge Order Service

The Order Service is a core microservice in the DataBridge architecture, responsible for managing orders, payments, and shipments across the platform. It provides APIs for order processing and fulfillment within the larger DataBridge ecosystem.

## Overview

The Order Service is built using Ruby on Rails in API-only mode, implementing an event-driven architecture to handle the complete order lifecycle. It's part of the larger DataBridge system which enables seamless data sharing across multiple applications.

## Features

- **Order Management**: Create, read, update, and cancel orders
- **Line Item Management**: Track products, quantities, and prices within orders
- **Payment Processing**: Record and track payment information
- **Shipment Tracking**: Manage the fulfillment and delivery process
- **Status Transitions**: Handle the complete order lifecycle
- **Event Publishing & Subscribing**: Communicate changes with other services

## API Endpoints

### Orders
- `GET /api/v1/orders`: List all orders with filtering options
- `GET /api/v1/orders/:id`: Get a specific order with details
- `POST /api/v1/orders`: Create a new order
- `PUT /api/v1/orders/:id`: Update an order's status
- `DELETE /api/v1/orders/:id`: Cancel an order

### Payments
- `GET /api/v1/orders/:order_id/payments`: List payments for an order
- `POST /api/v1/orders/:order_id/payments`: Record a new payment

### Shipments
- `GET /api/v1/orders/:order_id/shipments`: List shipments for an order
- `POST /api/v1/orders/:order_id/shipments`: Create a new shipment
- `PUT /api/v1/orders/:order_id/shipments/:id`: Update shipment status

## Data Models

### Order
- `customer_id`: Associated customer
- `status`: Order status (created, processing, fulfilled, canceled)
- `total_amount`: Total order value
- `notes`: Additional order notes

### LineItem
- `order_id`: Associated order
- `product_id`: Product reference
- `quantity`: Quantity ordered
- `unit_price`: Price per unit at time of order
- `total_price`: Total price for the line item

### Payment
- `order_id`: Associated order
- `amount`: Payment amount
- `payment_method`: Method used (credit_card, paypal, bank_transfer)
- `status`: Payment status (pending, completed, failed)
- `transaction_id`: External payment reference

### Shipment
- `order_id`: Associated order
- `tracking_number`: Shipment tracking ID
- `carrier`: Shipping carrier
- `status`: Shipment status (pending, shipped, delivered, returned)

## Event Publishing

The service publishes the following events to notify other services about changes:

- `OrderCreated`: When a new order is created
- `OrderStatusChanged`: When an order's status is updated
- `PaymentProcessed`: When a payment is recorded
- `ShipmentUpdated`: When shipment status changes

## Event Subscriptions

The Order Service subscribes to these events from other services:

- `CustomerUpdated`: To handle customer changes affecting orders
- `ProductUpdated`: To handle product changes affecting orders
- `InventoryChanged`: To handle inventory changes affecting orders

## Setup & Installation

### Prerequisites
- Ruby 3.2.2
- Rails 7.1
- PostgreSQL
- Kafka/RabbitMQ for event messaging

### Installation

1. Clone the repository:
   ```
   git clone https://github.com/your-org/databridge-order-service.git
   cd databridge-order-service
   ```

2. Install dependencies:
   ```
   bundle install
   ```

3. Setup the database:
   ```
   rails db:create db:migrate db:seed
   ```

4. Configure environment variables:
   ```
   cp .env.example .env
   # Edit .env with your configuration
   ```

5. Start the server:
   ```
   rails s -p 3003
   ```

## Testing

Run the test suite with:

```
rails spec
```

## Dependencies

- `databridge_shared`: Shared utilities for the DataBridge platform
- `jwt`: For JWT authentication
- `kafka-ruby`: For event publishing
- `kaminari`: For pagination

## Integration with Other Services

The Order Service interacts with other DataBridge services:
- **API Gateway**: Routes order-related requests to this service
- **Customer Service**: Provides customer data for orders
- **Product Service**: Provides product data and inventory information
- **Analytics Service**: Consumes order events for reporting

## Business Logic Flows

### Order Creation Flow
1. Receive order creation request with customer ID and line items
2. Validate line items against Product Service
3. Calculate order total
4. Create order with "created" status
5. Publish OrderCreated event

### Payment Processing Flow
1. Receive payment details for an order
2. Record payment information
3. Update payment status
4. If payment completed, update order to "processing"
5. Publish PaymentProcessed event

### Shipment Flow
1. Create shipment record for processed order
2. Update shipment status as it progresses
3. When shipment delivered, update order to "fulfilled"
4. Publish ShipmentUpdated event

## Development

### Adding New Order Features

1. Add the model and migrations
2. Create the controller and routes
3. Implement event publishing
4. Update the API documentation (Swagger)

### Creating New Event Types

1. Define the event schema in `databridge_shared` gem
2. Add the publishing code to the relevant model
3. Create handlers in consuming services

## Related Services

- [DataBridge API Gateway](https://github.com/Niraj22/databridge-api-gateway)
- [DataBridge Customer Service](https://github.com/Niraj22/databridge-customer-service)
- [DataBridge Product Service](https://github.com/Niraj22/databridge-product-service)
- [DataBridge Analytics Service](https://github.com/Niraj22/databridge-analytics-service)

## License

[MIT License](LICENSE)
