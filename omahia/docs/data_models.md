# Omahia Marketplace - Core Data Models (Conceptual)

This document outlines the basic structure of the core data models for the Omahia multi-vendor marketplace. This is a conceptual overview and will be refined during database schema design and implementation.

## 1. User

Represents any individual interacting with the platform. Users can have different roles (buyer, seller, admin).

**Attributes:**

*   `userId`: Unique identifier (e.g., UUID, auto-incrementing ID) - Primary Key
*   `firstName`: String
*   `lastName`: String
*   `email`: String (unique, used for login)
*   `passwordHash`: String (hashed password)
*   `phoneNumber`: String (optional)
*   `profilePictureUrl`: String (optional)
*   `roles`: Array of Strings (e.g., \["buyer", "seller"], \["buyer"], \["admin"])
*   `isActive`: Boolean (for account activation/deactivation)
*   `isVerified`: Boolean (for email/phone verification)
*   `createdAt`: Timestamp
*   `updatedAt`: Timestamp

**Seller-Specific Attributes (if role includes "seller"):**

*   `storeName`: String (unique if required)
*   `storeDescription`: Text
*   `storeLogoUrl`: String (optional)
*   `businessAddress`: Object/String (address details)
*   `payoutDetails`: Object (e.g., Paystack account info for settlements) - *To be securely handled*
*   `sellerRating`: Number (average rating from buyers)

## 2. Product

Represents an item listed for sale by a seller.

**Attributes:**

*   `productId`: Unique identifier - Primary Key
*   `sellerId`: Foreign Key (references `User.userId` of the seller)
*   `name`: String
*   `description`: Text
*   `category`: String (or Foreign Key to a `Category` model if categories are complex)
*   `price`: Decimal (currency amount)
*   `currency`: String (e.g., "NGN", "USD") - *Consider standardizing or linking to Paystack's supported currencies*
*   `stockQuantity`: Integer
*   `images`: Array of Strings (URLs to product images)
*   `sku`: String (Stock Keeping Unit, optional, unique per seller)
*   `attributes`: Object/JSON (e.g., size, color, material - can be flexible)
*   `isActive`: Boolean (whether the product is listed or hidden)
*   `isFeatured`: Boolean (for promotional purposes, optional)
*   `averageRating`: Number (average rating from buyers)
*   `createdAt`: Timestamp
*   `updatedAt`: Timestamp

## 3. Order

Represents a transaction where a buyer purchases one or more products from one or more sellers.

**Attributes:**

*   `orderId`: Unique identifier - Primary Key
*   `buyerId`: Foreign Key (references `User.userId` of the buyer)
*   `orderDate`: Timestamp
*   `status`: String (e.g., "pending_payment", "paid", "processing", "shipped", "delivered", "cancelled", "refunded")
*   `totalAmount`: Decimal (total cost of the order)
*   `currency`: String
*   `shippingAddress`: Object/String (address details)
*   `billingAddress`: Object/String (address details, optional if same as shipping)
*   `paymentId`: Foreign Key (references `Payment.paymentId`)
*   `createdAt`: Timestamp
*   `updatedAt`: Timestamp

**Order Items (Line Items - typically a separate related table/document collection):**

*   `orderItemId`: Unique identifier - Primary Key
*   `orderId`: Foreign Key (references `Order.orderId`)
*   `productId`: Foreign Key (references `Product.productId`)
*   `sellerId`: Foreign Key (references `User.userId` of the seller for this item) - *Important for multi-vendor payouts*
*   `quantity`: Integer
*   `unitPrice`: Decimal (price at the time of purchase)
*   `totalPrice`: Decimal (`quantity` * `unitPrice`)
*   `productSnapshot`: Object/JSON (a copy of key product details at the time of purchase, for historical accuracy)

## 4. Payment

Represents a payment transaction processed through Paystack.

**Attributes:**

*   `paymentId`: Unique identifier - Primary Key (could be Paystack's transaction ID/reference)
*   `orderId`: Foreign Key (references `Order.orderId`)
*   `paystackReference`: String (Paystack's unique transaction reference)
*   `amount`: Decimal
*   `currency`: String
*   `status`: String (e.g., "pending", "success", "failed", "abandoned" - reflecting Paystack status)
*   `paymentMethod`: String (e.g., "card", "bank_transfer" - as reported by Paystack)
*   `gatewayResponse`: Object/JSON (full response from Paystack for auditing/debugging)
*   `paidAt`: Timestamp (when payment was confirmed successful)
*   `createdAt`: Timestamp
*   `updatedAt`: Timestamp

## Relationships (Summary)

*   A **User** (seller) can have many **Products**.
*   A **User** (buyer) can place many **Orders**.
*   An **Order** belongs to one **Buyer** (User).
*   An **Order** has one associated **Payment**.
*   An **Order** consists of one or more **OrderItems**.
*   Each **OrderItem** links to a **Product** and its **Seller** (User).
*   A **Product** belongs to one **Seller** (User).

This conceptual model will serve as a basis for designing the database schema and API endpoints. Further details and potential supporting models (e.g., Categories, Reviews, ShippingMethods) will be considered as development progresses.
