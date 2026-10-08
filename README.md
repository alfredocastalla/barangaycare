# BarangayCare

BarangayCare is a client-server prototype for a Digital Beneficiary Management and Social Assistance Monitoring with Scheduling System for Barangay Taft, Surigao City.

## Run the Laravel app on Windows

1. Start WAMP's MySQL service.
2. Double-click `start-laravel.bat` in the project folder. It finds WAMP's PHP 8.3+ executable, prepares Laravel's `.env` and application key when needed, creates the configured database if needed, runs Laravel migrations and seeders, then starts `php artisan serve`.
3. Open `http://127.0.0.1:8000`. Keep the command window open while using the system.

Local `php.bat` launchers in the project root and `laravel-api/` select WAMP PHP 8.4/8.3, so `php artisan serve` works in Windows Command Prompt without a global PHP PATH change. In VS Code, new integrated terminals also add WAMP PHP to PATH. From `laravel-api/`, run `php artisan serve`; Artisan prints the local URL `http://127.0.0.1:8000`. Use `composer install` or `composer --version` there; `composer.bat` calls the same PHP launcher and project-root `composer.phar`. Double-click `start-laravel.bat` if you need automatic database preparation before starting the server.

Laravel is the system's only active backend: it serves the interface, provides the API, creates the schema with migrations, and stores records in MySQL. If you already have a Laravel `.env` file, the launcher leaves it unchanged; check its `DB_CONNECTION`, `DB_DATABASE`, `DB_USERNAME`, and `DB_PASSWORD` values if setup cannot connect.

Screen navigation uses Laravel URLs: role selection opens paths such as `/login/barangay`, and sidebar pages open paths such as `/app/barangay/beneficiaries`. These links can be refreshed or shared within the running app, and browser back/forward restores the selected screen. The prototype keeps only the current account's non-password display fields in tab-scoped browser storage so a page refresh can restore the screen; this is not server-side Laravel authentication.

## Project Structure

- `laravel-api/` contains the Laravel application, API, migrations, seeders, and served interface.
- `start-laravel.bat` starts Laravel using the PHP version installed with WAMP.
- `index.html` redirects to the Laravel-served app.

## Offline Use

The browser can cache the interface for offline access, but saving or loading system records requires the Laravel backend and its database to be running.

For best offline behavior:

1. Start WAMP MySQL and run `start-laravel.bat`.
2. Open `http://127.0.0.1:8000`.
3. Wait for the page to finish loading.
4. The cached interface can reopen offline, but API actions will be unavailable until Laravel is running again.

## Assistance Email Notifications

Configure these values in `laravel-api/.env` to send resident notifications through Gmail SMTP:

```dotenv
MAIL_MAILER=smtp
MAIL_SCHEME=smtps
MAIL_HOST=smtp.gmail.com
MAIL_PORT=465
MAIL_USERNAME=your-gmail-address
MAIL_PASSWORD=your-gmail-app-password
MAIL_FROM_ADDRESS="${MAIL_USERNAME}"
MAIL_FROM_NAME="${APP_NAME}"
```

Use a Gmail App Password, not your normal account password. Check the mail configuration at `http://127.0.0.1:8000/api/mail-status`. Laravel reads `.env` when it starts, so restart the server after changing these values.

On the sign-up page, choose **Staff** or **Super Admin**. Both account types are active immediately. After sign-in, Laravel uses the role saved with the account—not the login page selected—to open the correct dashboard. Existing Pending Staff or Super Admin accounts are activated when they sign in with the correct username and password. **Important:** because public self-registration can now create Super Admin accounts, this behavior is suitable only for a trusted/local prototype; restrict or disable public registration before exposing the system to the internet. Resident sign-up is not offered publicly; staff create resident accounts from **Users → Add Resident Account**, link the account to an existing beneficiary, and confirm their staff password. On the sign-in page, use the existing account credentials:

- Residents: `user` / `password`
- Super Admin (Admin account): `admin` / `password`
- Staff (Barangay account): `barangay` / `password`

Staff account applications can be opened from the sign-in page using **Submit an account application**. Staff-created residents sign in using their new username/password and the Residents sign-in route. Passwords created or changed through Laravel are hashed, and account data responses do not include password fields.

## Included Modules

- Role-based login interfaces for User, Admin, and Barangay staff
- User dashboard for assistance records, schedules, reports, profile, and settings
- Admin dashboard for user management, modules, audit logs, backup, activity monitoring, and system settings
- Barangay dashboard for beneficiaries, programs, assistance distribution, monitoring, reports, users, and settings
- Beneficiary registration and real-time record updates
- Beneficiary editing and status management
- Assistance recording and tracking
- Assistance claim confirmation and claimed-date tracking
- Program scheduling
- Program editing and completion status management
- User account creation, editing, activation, and deactivation
- Search and filtering
- Printable reports
- Database-backed backup download through the Laravel API
- Laravel-backed assistant for assistance questions and release-message logging
- Browser-based audit activity log stored through the Laravel API

## Requested Feature Checklist

1. Beneficiary registration and profile management: implemented.
2. Social assistance monitoring and tracking: implemented.
3. Assistance program and barangay activity scheduling: implemented.
4. User authentication and role-based access control: implemented for Admin, Barangay, and User roles.
5. Report generation and printing: implemented.
6. Audit logs: implemented and stored in MySQL.
7. Real-time dashboard summaries: implemented from the active backend data.
8. Beneficiary search and filtering: implemented.
9. Web admin panel and responsive mobile layout: implemented.
10. Laravel/MySQL storage: the Laravel API and MySQL database are the active persistence backend.

The Laravel-served application uses Laravel's API and database.

## How to Run with WAMP

1. Copy the whole project folder into `C:\wamp64\www\barangaycare`.
2. Start WAMP's MySQL service. Laravel creates `barangaycare_db` when the launcher runs.
3. Run `start-laravel.bat`.
4. Open `http://127.0.0.1:8000`.
5. Check the Laravel API at `http://127.0.0.1:8000/api/health`.

Default login accounts (choose the matching role above):

- Residents: `user` / `password`
- Super Admin (Admin account): `admin` / `password`
- Staff (Barangay account): `barangay` / `password`

## Technology Implementation

BarangayCare is structured as a web-based and mobile-accessible client-server application. The front end uses HTML, CSS, JavaScript, and ReactJS through browser CDN scripts. The interface is responsive, role-based, and designed for non-technical barangay staff and beneficiaries.

Laravel routes in `laravel-api/routes/web.php` serve the frontend, while `laravel-api/routes/api.php` handles authentication, data access, health checks, mail status, notifications, assistant answers, and database-backed backups. Mutating actions save to MySQL through Laravel before the interface reports success.

The browser uses the clean Laravel API paths below. Older `.php` API paths remain available as compatibility aliases.

| Purpose | Laravel API route |
| --- | --- |
| Database connection | `GET /api/health` |
| Read/write application data | `GET /api/data`, `POST /api/data` |
| Sign in | `POST /api/auth` |
| Check data version | `GET /api/version` |
| Send assistance notification | `POST /api/notify-assistance` |
| Check SMTP configuration | `GET /api/mail-status` |
| Export database backup | `GET /api/backup` |
| Ask the assistance helper | `POST /api/chat` |

From `laravel-api/`, use `php artisan route:list --path=api` to inspect registered API endpoints and `php artisan serve --host=127.0.0.1 --port=8000` to run the app. On the documented WAMP setup, `start-laravel.bat` selects PHP and prepares the database before starting the Laravel server.

MySQL stores each application area in its own table:

- `beneficiaries` stores resident records.
- `programs` stores schedules.
- `assistance` stores assistance and claim records.
- `users` stores login accounts and profile fields.
- `logs` stores audit activity.
- `settings` stores system settings.
- `app_state` is retained as a compatibility copy.

Laravel migrations create and upgrade the tables. The Laravel seeder loads the demo records for a new database and can import data from an existing `app_state` compatibility row.

## Capstone Presentation Highlights

- ReactJS front end for dynamic dashboard rendering and module navigation
- Laravel/PHP backend using MySQL
- Role-based access for Admin, Barangay Staff, and User accounts
- Beneficiary management with duplicate checking
- Assistance monitoring with status tracking
- Claim confirmation workflow for received assistance
- Scheduling module for assistance programs
- Account-to-beneficiary privacy linking
- AI message assistant for release schedule notices
- Printable reports and backup export
- Audit logs for accountability

The interface is served from `laravel-api/public`; page routes are registered in `laravel-api/routes/web.php`, while application APIs are registered in `laravel-api/routes/api.php` and implemented by Laravel controllers.

## Security and Access Control

The prototype includes role-based navigation for Admin, Barangay Staff, and User accounts.
