# Sunbird Garden - High Level Design Document

**Version:** 1.0
**Date:** 2025-11-26
**Status:** Draft
**Project Type:** Platform (Multi-Service)

---

## 1. Overview

Sunbird Garden is a dynamic forms builder platform that enables users to create, edit, preview, and manage custom forms with multiple field types. The platform provides a flexible, code-free approach to building data collection forms with support for validation, multi-select options, and various input types.

### Purpose
- Enable non-technical users to build and deploy custom forms
- Support multiple field types (text, number, email, date, checkbox, dropdown, multiselect)
- Provide real-time form preview and editing capabilities
- Store form configurations and submissions for later retrieval

### Target Users
- Business analysts and product managers
- Customer support teams
- Marketing teams collecting lead information
- Internal teams requiring custom data collection forms

---

## 2. Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                         CLIENT LAYER                             │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │           Angular 18 SPA (sunbird-frontend)                │ │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────────────────────┐ │ │
│  │  │  Form    │  │  Form    │  │  Form Preview &          │ │ │
│  │  │  Editor  │  │  Manager │  │  Submission              │ │ │
│  │  └──────────┘  └──────────┘  └──────────────────────────┘ │ │
│  │       │              │                    │                 │ │
│  │       └──────────────┴────────────────────┘                 │ │
│  │                      │                                       │ │
│  │              ┌───────▼────────┐                             │ │
│  │              │  Forms Service │                             │ │
│  │              │  (In-Memory)   │                             │ │
│  │              └───────┬────────┘                             │ │
│  └──────────────────────┼──────────────────────────────────────┘ │
└─────────────────────────┼────────────────────────────────────────┘
                          │
                   HTTP/REST API
                          │
┌─────────────────────────▼────────────────────────────────────────┐
│                      API LAYER                                   │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │         Custom PHP Backend (sunbird-api)                   │ │
│  │  ┌──────────────┐  ┌──────────────┐  ┌────────────────┐  │ │
│  │  │   Router     │─▶│   Routes     │─▶│  ApiResponse   │  │ │
│  │  │  (Minimalist │  │  (Handlers)  │  │   Models       │  │ │
│  │  │     MVC)     │  └──────┬───────┘  └────────────────┘  │ │
│  │  └──────────────┘         │                               │ │
│  │                   ┌────────▼────────┐                      │ │
│  │                   │ Database Layer  │                      │ │
│  │                   │   (Functions)   │                      │ │
│  │                   └────────┬────────┘                      │ │
│  └────────────────────────────┼───────────────────────────────┘ │
└─────────────────────────────┼─────────────────────────────────────┘
                              │
                    PostgreSQL Protocol
                              │
┌─────────────────────────────▼────────────────────────────────────┐
│                      DATA LAYER                                  │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │                  PostgreSQL Database                        │ │
│  │  ┌──────────┐  ┌───────────────┐  ┌───────────────────┐  │ │
│  │  │  Tables  │  │   Stored      │  │   User Auth &     │  │ │
│  │  │  (Forms, │  │   Procedures  │  │   Permissions     │  │ │
│  │  │   Users) │  │   (Business   │  │                   │  │ │
│  │  │          │  │    Logic)     │  │                   │  │ │
│  │  └──────────┘  └───────────────┘  └───────────────────┘  │ │
│  └────────────────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                    EXTERNAL SERVICES                             │
│  ┌─────────────┐  ┌──────────────┐  ┌────────────────────────┐ │
│  │   JWT Auth  │  │   ZeptoMail  │  │   Excel Export         │ │
│  │  (firebase/ │  │   (Email     │  │   (PHPSpreadsheet)     │ │
│  │   php-jwt)  │  │   Service)   │  │                        │ │
│  └─────────────┘  └──────────────┘  └────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                    DEPLOYMENT LAYER                              │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │               Docker Container (Debian 12)                  │ │
│  │  ┌──────────────┐  ┌──────────────┐  ┌─────────────────┐  │ │
│  │  │   Apache2    │  │    PHP 8.x   │  │   Node.js 20    │  │ │
│  │  │   (Web       │  │   (Backend)  │  │   (Build Tools) │  │ │
│  │  │   Server)    │  │              │  │   Angular CLI   │  │ │
│  │  └──────────────┘  └──────────────┘  └─────────────────┘  │ │
│  └────────────────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────────────────┘
```

---

## 3. Tech Stack

### Frontend Service (sunbird-frontend)

| Category | Technology | Version | Purpose |
|----------|-----------|---------|---------|
| Framework | Angular | 18.2.0 | SPA framework for building dynamic UI |
| UI Framework | Bootstrap | 5.3.3 | Responsive CSS framework |
| Language | TypeScript | 5.5.2 | Type-safe JavaScript superset |
| State Management | RxJS | 7.8.0 | Reactive programming for async operations |
| Build Tool | Angular CLI | 18.2.1 | Development and build toolchain |
| Testing | Jasmine + Karma | 5.2.0 / 6.4.0 | Unit testing framework |

### Backend Service (sunbird-api)

| Category | Technology | Version | Purpose |
|----------|-----------|---------|---------|
| Language | PHP | 8.x | Server-side scripting language |
| Framework | Custom MVC | 0.2.0 | Minimalistic routing and controller framework |
| Database | PostgreSQL | Latest | Primary data store with stored procedures |
| Authentication | firebase/php-jwt | 6.10 | JWT token generation and validation |
| Excel Export | phpoffice/phpspreadsheet | 2.0 | Generate Excel files for data export |
| Email Service | ZeptoMail | N/A | Transactional email delivery |
| Web Server | Apache2 | Latest | HTTP server with mod_php |

### Development & Deployment

| Category | Technology | Version | Purpose |
|----------|-----------|---------|---------|
| Container | Docker | Latest | Containerized deployment |
| Base Image | Debian | 12.10-slim | Lightweight Linux distribution |
| Node.js | NVM + Node | 20.17.0 | JavaScript runtime for build tools |
| Version Control | Git | Latest | Source code management |

---

## 4. Services Table

| Service Name | Type | Port | Technology | Purpose | Status |
|-------------|------|------|------------|---------|--------|
| **sunbird-frontend** | Frontend SPA | 4200 (dev) | Angular 18 + TypeScript | Dynamic forms builder UI with form editor, preview, and management capabilities | WIP |
| **sunbird-api** | Backend API | 80/443 | Custom PHP + PostgreSQL | REST API providing form CRUD operations, user authentication, and data persistence via stored procedures | WIP |

### Service Dependencies

```
sunbird-frontend
    └─► sunbird-api (REST API calls)
            └─► PostgreSQL Database
            └─► JWT Authentication (firebase/php-jwt)
            └─► ZeptoMail (Email notifications)
            └─► PHPSpreadsheet (Excel exports)
```

---

## 5. Data Model

### Database Schema (PostgreSQL)

#### Core Tables

```sql
-- Users Table
users (
    user_id: SERIAL PRIMARY KEY,
    name: TEXT NOT NULL,
    email: TEXT NOT NULL,
    is_email_verified: BOOLEAN DEFAULT FALSE,
    email_verified_on: TIMESTAMPTZ NULL,
    created_on: TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_updated_on: TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
)

-- Forms Table (expected structure)
forms (
    form_id: SERIAL PRIMARY KEY,
    form_name: TEXT NOT NULL,
    form_config: JSONB NOT NULL,  -- Stores DynamicForm structure
    created_by: INTEGER REFERENCES users(user_id),
    created_on: TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_on: TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    is_active: BOOLEAN DEFAULT TRUE
)

-- Form Submissions Table (expected structure)
form_submissions (
    submission_id: SERIAL PRIMARY KEY,
    form_id: INTEGER REFERENCES forms(form_id),
    submitted_by: INTEGER REFERENCES users(user_id) NULL,
    submission_data: JSONB NOT NULL,
    submitted_on: TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ip_address: TEXT,
    user_agent: TEXT
)
```

### Frontend Data Models

#### DynamicFormField Interface
```typescript
interface DynamicFormField {
    id?: string
    name: string
    label?: string
    type: DynamicFormFieldType  // Enum: number, text, email, secret,
                                //       multilinetext, checkbox, hidden,
                                //       dropdown, multiselect, date
    hidden?: boolean
    value?: string | number | boolean | DynamicFormMultiSelectValue[]
    source?: DynamicFormMultiSelectSource  // For dropdown/multiselect
    required?: boolean
}
```

#### DynamicForm Type
```typescript
type DynamicForm = {
    formName: string
    fields: DynamicFormField[]
    buttons: DynamicFormButton[]
}
```

#### Field Types Supported

| Type | Control | Description | Example Use Case |
|------|---------|-------------|------------------|
| `text` | Text input | Single-line text entry | Name, Title |
| `number` | Number input | Numeric values | Age, Quantity |
| `email` | Email input | Email validation | Contact Email |
| `secret` | Password input | Hidden text | Password fields |
| `multilinetext` | Textarea | Multi-line text | Comments, Description |
| `checkbox` | Checkbox | Boolean yes/no | Accept Terms |
| `hidden` | Hidden field | Invisible data | Tracking IDs |
| `dropdown` | Select | Single selection from list | Country, Status |
| `multiselect` | Multi-select | Multiple selections | Skills, Tags |
| `date` | Date picker | Date selection | Birth Date, Event Date |

### API Response Model

```php
class ApiResponse {
    string $status;      // 'ok', 'error', 'warning'
    string $message;     // Human-readable message
    array $data;         // Response payload
    int $httpCode;       // HTTP status code
}
```

---

## 6. Key Features

### Form Builder Features
1. **Visual Form Editor**
   - Drag-and-drop field management
   - Add/remove fields dynamically
   - Configure field properties (label, type, required, validation)
   - Reorder fields

2. **Field Types Support**
   - 10+ field types covering common use cases
   - Custom validation rules per field
   - Conditional field visibility
   - Multi-select with custom data sources

3. **Form Preview**
   - Real-time form rendering
   - Test form submission flow
   - Preview responsive layouts
   - Validation testing

4. **Form Management**
   - List all created forms
   - Edit existing forms
   - Duplicate forms
   - Archive/delete forms
   - Version control (planned)

### Backend Features
1. **Custom PHP MVC Framework**
   - Reflection-based request parsing
   - Automatic route generation
   - Stored procedure abstraction layer

2. **Database-First Approach**
   - Business logic in PostgreSQL stored procedures
   - Auto-generation of PHP models from SQL functions
   - Type-safe database calls

3. **Authentication & Authorization**
   - JWT-based authentication
   - Token generation and validation
   - User session management
   - Email verification workflow

4. **Data Export**
   - Excel export via PHPSpreadsheet
   - CSV export support
   - Custom report generation

5. **Email Integration**
   - Transactional emails via ZeptoMail
   - Email verification
   - Form submission notifications

---

## 7. Integrations

### Current Integrations

| Service | Purpose | Integration Type | Status |
|---------|---------|------------------|--------|
| **PostgreSQL** | Primary database | Direct connection | Active |
| **Firebase PHP JWT** | Authentication | PHP Library | Active |
| **ZeptoMail** | Transactional emails | REST API | Active |
| **PHPSpreadsheet** | Excel generation | PHP Library | Active |

### Integration Flow

```
Frontend (Angular)
    │
    ├─► Forms Service (In-Memory) ──► Local form state management
    │
    └─► HTTP Client ──► Backend API ──┬─► PostgreSQL (Data persistence)
                                       ├─► JWT (Auth validation)
                                       ├─► ZeptoMail (Email notifications)
                                       └─► PHPSpreadsheet (Export data)
```

---

## 8. External Dependencies

### NPM Packages (Frontend)

| Package | Version | Purpose | Critical |
|---------|---------|---------|----------|
| `@angular/core` | 18.2.0 | Core Angular framework | Yes |
| `@angular/forms` | 18.2.0 | Form handling and validation | Yes |
| `@angular/router` | 18.2.0 | SPA routing | Yes |
| `bootstrap` | 5.3.3 | UI styling | No |
| `rxjs` | 7.8.0 | Reactive programming | Yes |
| `typescript` | 5.5.2 | Type system | Yes |
| `zone.js` | 0.14.10 | Angular change detection | Yes |

### Composer Packages (Backend)

| Package | Version | Purpose | Critical |
|---------|---------|---------|----------|
| `firebase/php-jwt` | 6.10 | JWT token handling | Yes |
| `phpoffice/phpspreadsheet` | 2.0 | Excel file generation | No |

### System Dependencies

| Package | Version | Purpose | Critical |
|---------|---------|---------|----------|
| PHP | 8.x | Backend runtime | Yes |
| PostgreSQL | Latest | Database | Yes |
| Apache2 | Latest | Web server | Yes |
| Node.js | 20.17.0 | Build tools | Yes |
| Angular CLI | 18 | Development CLI | Yes |

---

## 9. Deployment

### Deployment Architecture

**Environment:** Docker Container (Debian 12.10-slim)

```
Docker Container
    ├── Apache2 (Web Server)
    │   └── Serves: PHP backend + Angular static files
    ├── PHP 8.x + mod_php
    │   └── Executes: sunbird-api
    ├── Node.js 20.17.0 (NVM)
    │   └── Builds: Angular frontend
    └── PostgreSQL (External)
        └── Connection: Via network
```

### Build Process

#### Frontend Build
```bash
cd sunbird-frontend
npm install
ng build --configuration production
# Output: dist/ directory with static files
# Deploy: Copy to Apache document root
```

#### Backend Deployment
```bash
cd sunbird-api
composer install
# Configure Apache virtual host
# Set .env for database connection
# Deploy: Copy to Apache /var/www/
```

### Container Configuration

**Base Image:** `debian:12.10-slim`

**Installed Components:**
- Apache2 with mod_php
- PHP 8.x with extensions: pgsql, curl, mbstring
- Node.js 20.17.0 (via NVM)
- Angular CLI 18
- Git for source control

**User:** `node` (UID: 1000, GID: 1000)

### Environment Variables

```bash
# Backend (.env)
DB_HOST=postgresql-host
DB_PORT=5432
DB_NAME=sunbird_db
DB_USER=sunbird_user
DB_PASSWORD=*****
JWT_SECRET=*****
ZEPTO_API_KEY=*****

# Frontend (environment.ts)
API_BASE_URL=https://api.sunbird.example.com
```

### Deployment Steps

1. **Build Docker Image**
   ```bash
   cd docker/debian-12v9-slim
   docker build -t sunbird-garden:latest .
   ```

2. **Run Container**
   ```bash
   docker run -d \
     -p 80:80 \
     -v /path/to/sunbird-api:/var/www/sunbird-api \
     -v /path/to/sunbird-frontend:/var/www/sunbird-frontend \
     --name sunbird-garden \
     sunbird-garden:latest
   ```

3. **Database Setup**
   ```bash
   # Run SQL scripts
   psql -h localhost -U postgres -f sunbird-api/App/Database/postgresql/tables/users.pssql
   # Run seed data
   psql -h localhost -U postgres -f sunbird-api/App/Database/postgresql/seeds/*.sql
   ```

4. **Apache Configuration**
   - Configure virtual hosts for API and frontend
   - Enable mod_rewrite for Angular routing
   - Set CORS headers for API

---

## 10. Shared Libraries Used

### Custom Framework (Backend)

The `sunbird-api` service uses a custom minimalistic PHP framework located in `/Framework/`:

| Component | File | Purpose |
|-----------|------|---------|
| **Router** | `Router.php` | Reflection-based HTTP routing system |
| **Database** | `Database.php` | PostgreSQL connection and query abstraction |
| **Logger** | `Logger.php` | Application logging |
| **Environment** | `Env.php` | Environment variable management |
| **Exceptions** | `Exceptions.php` | Custom exception handling |
| **Bootstrap** | `bootstrap.php` | Application initialization |
| **Error Handler** | `error_handler.php` | Global error handling |
| **Route Interface** | `IRouteHandler.php` | Interface for route handlers |

### CLI Tools (Backend)

| Tool | Purpose |
|------|---------|
| `generate-model.php` | Auto-generate PHP models from PostgreSQL functions |
| `generate-route.php` | Scaffold new route handlers |
| `dba.php` | Database administration utility |

### Common Patterns

1. **Database Functions Pattern**
   - SQL functions stored in `App/Database/postgresql/functions/`
   - PHP models auto-generated in `App/Database/Functions/`
   - Models call PostgreSQL stored procedures directly

2. **Route Handler Pattern**
   ```php
   class SomeRoute implements IRouteHandler {
       public function process() {
           // Parse request using reflection
           $data = FnSomeFunction::run($this->param1, $this->param2);
           return new ApiResponse('ok', '', ['data' => $data]);
       }
   }
   ```

3. **Frontend Service Pattern**
   - Services use RxJS observables
   - HTTP interceptors for auth tokens
   - Centralized error handling

---

## 11. Related Projects

### Progalaxy E-Labs Ecosystem

Sunbird Garden is part of the Progalaxy E-Labs project portfolio:

| Project | Relationship | Integration Points |
|---------|--------------|-------------------|
| **Work Management Tool** | Sibling Project | None currently |
| **Common Modules** | Potential Future | Shared auth, UI components |
| **Other Tools** | Sibling Projects | Potential shared backend framework |

### Reusable Components

The following components could be extracted as shared libraries:

1. **Custom PHP MVC Framework** (`/Framework/`)
   - Lightweight alternative to Laravel/Symfony
   - PostgreSQL-first approach
   - Could be packaged as Composer library

2. **Angular Dynamic Form Engine** (`/lib/dynamic-form.ts`)
   - Generic form builder components
   - Could be published as NPM package
   - Reusable across multiple projects

3. **Docker Development Environment**
   - Debian-based PHP+Angular+PostgreSQL stack
   - Could be template for other projects

---

## 12. Constraints

### Technical Constraints

1. **Custom Framework Limitations**
   - No ORM (uses raw stored procedures)
   - Limited middleware support
   - Manual route registration required
   - No automatic API documentation

2. **Frontend State Management**
   - Forms stored in-memory only (no persistence)
   - Page refresh loses unsaved forms
   - No offline support
   - No undo/redo functionality (yet)

3. **Database Constraints**
   - Tightly coupled to PostgreSQL
   - Business logic in stored procedures (portability issue)
   - No migration framework
   - Manual schema versioning

4. **Authentication**
   - JWT tokens only (no OAuth/SAML)
   - No refresh token mechanism (yet)
   - No multi-factor authentication
   - No role-based access control (yet)

5. **Performance**
   - No caching layer
   - No CDN integration
   - Single-server deployment only
   - No load balancing support

### Business Constraints

1. **Proprietary License**
   - Cannot be open-sourced without approval
   - Internal use only

2. **Development Status**
   - Work-in-progress (WIP)
   - Not production-ready
   - Limited documentation
   - No automated tests

3. **Resource Constraints**
   - Small development team
   - Limited QA resources
   - Manual deployment process

---

## 13. Technical Debt

### High Priority

1. **Testing**
   - **Issue:** No unit tests, integration tests, or e2e tests
   - **Impact:** High risk of regressions, difficult to refactor
   - **Effort:** 2-3 weeks
   - **Recommendation:** Implement Jest/Karma tests for frontend, PHPUnit for backend

2. **Form Persistence**
   - **Issue:** Forms only stored in-memory, lost on page refresh
   - **Impact:** Poor user experience, data loss
   - **Effort:** 1 week
   - **Recommendation:** Implement backend API for form CRUD operations

3. **API Documentation**
   - **Issue:** No OpenAPI/Swagger documentation
   - **Impact:** Difficult for frontend developers to consume API
   - **Effort:** 3-5 days
   - **Recommendation:** Add Swagger annotations or generate docs from code

4. **Error Handling**
   - **Issue:** Inconsistent error handling across services
   - **Impact:** Debugging difficulties, poor UX
   - **Effort:** 1 week
   - **Recommendation:** Standardize error codes, add global error interceptors

### Medium Priority

5. **Database Migrations**
   - **Issue:** No migration framework, manual schema changes
   - **Impact:** Deployment risks, version control issues
   - **Effort:** 1 week
   - **Recommendation:** Implement Flyway or custom migration system

6. **Authentication Enhancements**
   - **Issue:** No refresh tokens, no RBAC, no MFA
   - **Impact:** Security risks, limited access control
   - **Effort:** 2 weeks
   - **Recommendation:** Add refresh token flow, role-based permissions

7. **Caching Layer**
   - **Issue:** No caching, repeated database queries
   - **Impact:** Performance degradation under load
   - **Effort:** 1 week
   - **Recommendation:** Implement Redis for session and data caching

8. **Docker Compose**
   - **Issue:** No docker-compose.yml for multi-service orchestration
   - **Impact:** Complex local development setup
   - **Effort:** 2-3 days
   - **Recommendation:** Create docker-compose with all services

### Low Priority

9. **Code Documentation**
   - **Issue:** Minimal inline comments and README files
   - **Impact:** Onboarding difficulties
   - **Effort:** Ongoing
   - **Recommendation:** Add JSDoc/PHPDoc comments, improve README

10. **Commented-Out Code**
    - **Issue:** Large blocks of commented code in `dynamic-form.ts`
    - **Impact:** Code clutter, maintenance confusion
    - **Effort:** 1 day
    - **Recommendation:** Remove dead code, use git history instead

11. **Environment Configuration**
    - **Issue:** No .env.example file, hardcoded configuration
    - **Impact:** Difficult to set up new environments
    - **Effort:** 2-3 days
    - **Recommendation:** Create .env.example with all required variables

12. **Build Optimization**
    - **Issue:** No production build optimizations (minification, tree-shaking)
    - **Impact:** Larger bundle sizes, slower load times
    - **Effort:** 1 week
    - **Recommendation:** Configure production builds with AOT, lazy loading

---

## Appendix

### A. File Structure

```
sunbird-garden/
├── docker/                          # Docker configurations
│   ├── debian-12v9-slim/
│   │   └── Dockerfile
│   └── alpine/
│       └── Dockerfile
├── sunbird-api/                     # Backend PHP service
│   ├── App/
│   │   ├── Database/
│   │   │   ├── Functions/          # Auto-generated models
│   │   │   └── postgresql/
│   │   │       ├── functions/      # SQL stored procedures
│   │   │       ├── tables/         # Schema definitions
│   │   │       └── seeds/          # Seed data
│   │   ├── Routes/                 # API route handlers
│   │   ├── config/                 # Configuration files
│   │   ├── lib/                    # Custom libraries
│   │   └── models/                 # Domain models
│   ├── Framework/                  # Custom MVC framework
│   │   └── cli/                    # CLI tools
│   ├── public/                     # Web root
│   │   └── index.php              # Entry point
│   ├── vendor/                     # Composer dependencies
│   ├── composer.json
│   └── README.md
└── sunbird-frontend/               # Frontend Angular service
    ├── src/
    │   ├── app/
    │   │   ├── components/        # Reusable UI components
    │   │   ├── pages/             # Route components
    │   │   │   ├── form-editor/
    │   │   │   ├── form-preview-page/
    │   │   │   ├── forms/
    │   │   │   └── home/
    │   │   ├── services/          # Business logic services
    │   │   │   ├── forms.service.ts
    │   │   │   └── dynamic-form.service.ts
    │   │   ├── lib/               # Shared models and utilities
    │   │   │   ├── dynamic-form.ts
    │   │   │   └── my-form-field-model.ts
    │   │   ├── app.component.ts
    │   │   ├── app.config.ts
    │   │   └── app.routes.ts
    │   └── index.html
    ├── package.json
    └── angular.json
```

### B. Key Workflows

#### Creating a New API Endpoint

1. Create PostgreSQL function: `App/Database/postgresql/functions/my_function.pssql`
2. Generate PHP model: `php Framework/cli/generate-model.php my_function.pssql`
3. Generate route handler: `php Framework/cli/generate-route.php my-route`
4. Register route in `App/config/routes.php`
5. Implement logic in `App/Routes/MyRouteRoute.php`

#### Creating a New Form

1. Navigate to Form Editor page
2. Add fields with desired types
3. Configure field properties (label, validation, etc.)
4. Preview form
5. Save form (currently in-memory only)
6. Use form key to access in Form Preview page

### C. API Endpoints (Expected)

| Method | Endpoint | Purpose |
|--------|----------|---------|
| POST | `/api/auth/login` | User authentication |
| POST | `/api/auth/register` | User registration |
| GET | `/api/forms` | List all forms |
| POST | `/api/forms` | Create new form |
| GET | `/api/forms/:id` | Get form by ID |
| PUT | `/api/forms/:id` | Update form |
| DELETE | `/api/forms/:id` | Delete form |
| POST | `/api/forms/:id/submit` | Submit form data |
| GET | `/api/submissions` | List submissions |
| GET | `/api/export/excel` | Export data to Excel |

---

**Document Status:** Draft
**Next Review Date:** 2025-12-26
**Maintained By:** Development Team
**Contact:** pradeepdsmk@gmail.com
