# Paystack Integration Plan for Omahia Marketplace (Node.js Backend)

This document outlines the plan for integrating Paystack into the Omahia marketplace backend to handle payments.

## 1. Key Paystack API Endpoints & Features to Use:

Based on the Paystack developer documentation (`https://developers.paystack.co/`), the following are crucial:

*   **Transaction Initialization:**
    *   Endpoint: `POST /transaction/initialize`
    *   Purpose: To start a new payment process. The backend will send details like amount, email, currency, and a unique reference for the order.
    *   Response: Contains an `authorization_url` which the frontend will redirect the user to for completing the payment on Paystack's secure page. It also returns an `access_code` and `reference`.
*   **Transaction Verification:**
    *   Endpoint: `GET /transaction/verify/:reference`
    *   Purpose: After the user completes (or attempts) payment on Paystack and is redirected back to our site, the backend must call this endpoint using the transaction `reference` to confirm the payment status.
    *   Response: Contains the final status of the transaction (success, failed, abandoned), amount paid, currency, customer details, and other important information. This is the source of truth for payment confirmation.
*   **Webhooks:**
    *   Setup: Configure a webhook URL in the Paystack dashboard to point to an endpoint on our backend (e.g., `/api/paystack/webhooks`).
    *   Purpose: Paystack sends real-time event notifications (e.g., `charge.success`, `transfer.success`, `refund.processed`) to this URL. This is essential for:
        *   Reliably updating order status even if the user closes their browser before being redirected after payment.
        *   Handling events like successful refunds or chargebacks.
    *   Security: Webhook requests should be verified using the signature provided in the `x-paystack-signature` header to ensure they originate from Paystack.
*   **Split Payments (for Multi-Vendor Marketplace):**
    *   Feature: Paystack allows splitting a single customer payment among multiple recipients (subaccounts). This is vital for a multi-vendor marketplace where Omahia (as the platform) and individual sellers need to receive their respective shares of a transaction.
    *   Implementation:
        *   **Subaccounts:** Sellers will need to have Paystack subaccounts created and linked to Omahia's main Paystack account. The API for managing subaccounts (`POST /subaccount`, `GET /subaccount`, `PUT /subaccount/:id_or_code`) will be needed. This might involve an onboarding step for sellers.
        *   **Transaction Initialization with Splits:** When initializing a transaction, the `subaccount` code and `share` (percentage or flat amount for the subaccount) will be included in the payload. The `transaction_charge` can specify who bears the Paystack transaction fee.
*   **Refunds (Optional but Recommended):**
    *   Endpoint: `POST /refund`
    *   Purpose: To programmatically process full or partial refunds for transactions.
*   **Transfers (for Payouts to Sellers):**
    *   While Split Payments handle commission splitting at the point of sale, direct Transfers might be needed for manual payouts or adjustments.
    *   Endpoints:
        *   `POST /transferrecipient`: To create and save seller bank account details as transfer recipients.
        *   `POST /transfer`: To initiate a transfer to a recipient.
        *   `POST /transfer/bulk`: For processing multiple payouts at once.
        *   Webhooks for transfer status (e.g., `transfer.success`, `transfer.failed`).

## 2. Node.js Integration Strategy:

*   **Official/Recommended Library:** Check if Paystack provides an official Node.js SDK or a well-maintained community library. Using an SDK can simplify API calls, authentication, and type handling. (A quick search often reveals libraries like `paystack-node` or similar). If not, direct HTTPS requests will be made.
    *   *Self-correction during planning: A popular library is `paystack-node`. We should plan to use this.*
*   **Environment Variables:** Store Paystack API keys (Secret Key `SK_xxx`, Public Key `PK_xxx`) securely using environment variables (e.g., in a `.env` file, managed by the deployment environment). **Never commit API keys to the repository.**
*   **Service Module:** Create a dedicated `paystack.service.js` (or similar) in the backend to encapsulate all interactions with the Paystack API. This module will handle:
    *   Initializing the Paystack library/client with the secret key.
    *   Methods for `initializeTransaction`, `verifyTransaction`, `createSubaccount`, `processRefund`, `initiateTransfer`, etc.
    *   Error handling and logging for API calls.
*   **Webhook Handler:**
    *   Create a dedicated route (e.g., `POST /api/paystack/webhooks`).
    *   Implement signature verification for all incoming webhook events.
    *   Process events based on their `event` type (e.g., update order status on `charge.success`).
    *   Return a `200 OK` response quickly to Paystack to acknowledge receipt of the webhook, and process the event asynchronously if it involves complex logic.

## 3. Frontend Interaction Flow (High-Level):

1.  **Checkout:** User finalizes their cart and proceeds to checkout.
2.  **Initiate Payment Request:** Frontend sends order details (total amount, items) to the Omahia backend.
3.  **Backend Initializes Transaction:** Backend calls Paystack's `POST /transaction/initialize` API with amount, customer email, currency, and potentially split payment details.
4.  **Backend Responds to Frontend:** Backend sends the `authorization_url` (received from Paystack) back to the frontend.
5.  **Frontend Redirects to Paystack:** Frontend redirects the user's browser to the `authorization_url`.
6.  **User Pays on Paystack:** User completes payment using available methods on Paystack's secure page.
7.  **Paystack Redirects Back:** Paystack redirects the user back to a `callback_url` specified during initialization (e.g., `https://omahia.com/payment/callback?reference=xxx`).
8.  **Frontend Notifies Backend:** On the callback page, the frontend takes the `reference` from the URL.
9.  **Backend Verifies Transaction:** Frontend sends this `reference` to the Omahia backend. The backend then calls Paystack's `GET /transaction/verify/:reference` API.
10. **Backend Updates Order & Responds to Frontend:** Based on verification, the backend updates the order status (e.g., "paid", "failed") and informs the frontend.
11. **Frontend Displays Status:** Frontend shows the user the payment success or failure message.
12. **Webhook (Parallel):** Independently, Paystack sends a `charge.success` (or other relevant) event to the backend's webhook URL. The backend verifies and processes this, ensuring the order status is correctly updated even if the user drops off after payment before the redirect to callback URL completes.

## 4. Seller Onboarding for Splits (Considerations):

*   A process will be needed for sellers to provide their bank details or connect their Paystack account to be set up as a subaccount under Omahia's main account.
*   This might involve a section in the seller dashboard to input banking information, which the backend then uses to call Paystack's `POST /subaccount` API.
*   Secure storage and handling of sensitive seller payout information is critical.

## 5. Next Steps in Implementation (Post-Planning):

1.  Install a Paystack Node.js library (e.g., `npm install paystack-node`).
2.  Set up environment variables for API keys.
3.  Implement the `paystack.service.js` module with core functions (`initializeTransaction`, `verifyTransaction`).
4.  Create backend API endpoints for the frontend to call (e.g., `/api/orders/:orderId/initiate-payment`, `/api/payment/verify`).
5.  Implement the webhook handler endpoint with signature verification.
6.  Integrate subaccount creation and management for sellers.
7.  Thoroughly test with Paystack's test API keys and simulated scenarios.

This plan provides a foundational strategy for Paystack integration. Details will be refined during the actual implementation.
