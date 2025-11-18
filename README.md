# Subscription & Sale Tracker

Flutter dashboard for tracking client sales, linked subscriptions, and renewal reminders with Google Sheets (via Apps Script Web App) as the backend. The UI highlights upcoming renewals, lists recent sales, and provides searchable customer/sales directories with quick forms to add entries or mark payments.

## Features
- Home dashboard with near-due subscription cycles and latest sales.
- Sales tab with search, detail sheet, and ability to add subscriptions per sale.
- Customers tab with search + quick add form.
- Apps Script Web App client (or in-app mock data during local development).
- Local caching for offline read-only mode; writes require connectivity.

## Google Sheets Schema
Create three sheets within the same spreadsheet (tab names are case-sensitive unless you add mapping inside your Apps Script):

| Sheet | Columns |
| --- | --- |
| `Sales` | `saleId`, `customerId`, `title`, `description`, `dealValue`, `saleDate`, `channel`, `notes`, `createdAt`, `updatedAt` |
| `Subscriptions` | `subscriptionId`, `saleId`, `serviceName`, `billingCycle` (`MONTHLY`/`QUARTERLY`/`YEARLY`), `amount`, `nextDueDate`, `lastPaidDate`, `status` (`PENDING`/`PAID`/`OVERDUE`), `autoRenew` (`Y`/`N`), `notes` |
| `Customers` | `customerId`, `name`, `company`, `email`, `phone`, `address`, `notes`, `createdAt`, `updatedAt` |

IDs can be any unique string (e.g., `SALE-123`). The app expects ISO-8601 timestamps for date columns.

## Apps Script Web App
1. Create a new Apps Script project bound to the spreadsheet.
2. Implement REST-style handlers (e.g., `doGet`, `doPost`, `doPut`) that read `action` parameters: `fetchSales`, `fetchCustomers`, `fetchSubscriptions`, `createSale`, `upsertCustomer`, `addSubscription`, `markSubscriptionPaid`.
3. Deploy the project as a web app (access level: "Anyone with the link" or via an API key you validate manually). Note the deployment URL.
4. (Optional) Require an API key by checking the `apiKey` query parameter in every request.

## Configuration
The Flutter app reads runtime values via `--dart-define` flags. Common options:

```
flutter run \
	--dart-define=API_BASE_URL=https://script.google.com/macros/s/....../exec \
	--dart-define=API_KEY=your-secret-key \
	--dart-define=USE_MOCK_DATA=false
```

Leave `USE_MOCK_DATA=true` to use the bundled mock service before the backend is ready.

## Running Locally

```
flutter pub get
flutter run
```

### Tests & Static Analysis

```
flutter analyze
flutter test
```

## Folder Highlights
- `lib/models`: domain entities + draft payload helpers.
- `lib/services`: Apps Script client, mock service, and local cache.
- `lib/state`: Riverpod providers/notifiers.
- `lib/ui`: screens and form/bottom-sheet widgets.

## Next Steps / Ideas
- Push notifications or local reminders for upcoming renewals.
- Authentication layer before exposing write APIs.
- Charts for MRR/ARR trends using the cached data set.
