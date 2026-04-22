# Real Estate App — Flutter

A full-featured real estate mobile application built with Flutter, supporting property rental, buying/selling, owner listings, company project management, payments, chat, documents, and admin controls.

---

## Table of Contents

- [Overview](#overview)
- [Phase 1 — Auth Flow](#phase-1--auth-flow)
- [Phase 2 — User Dashboard](#phase-2--user-dashboard)
- [Phase 3 — Owner Dashboard](#phase-3--owner-dashboard)
- [Phase 4 — Seller Dashboard](#phase-4--seller-dashboard)
- [Phase 5 — Company Dashboard](#phase-5--company-dashboard)
- [Phase 6 — Payments](#phase-6--payments)
- [Phase 7 — Chat](#phase-7--chat)
- [Phase 8 — Documents](#phase-8--documents)
- [Phase 9 — Notifications](#phase-9--notifications)
- [Phase 10 — Admin Dashboard](#phase-10--admin-dashboard)

---

## Overview

This app serves four user roles — **User**, **Owner**, **Seller**, and **Company** — each with a dedicated dashboard and feature set. Built with clean architecture in Flutter, it integrates REST APIs for all data operations, Razorpay/Stripe for payments, real-time Socket.io chat, Firebase FCM push notifications, and DigiLocker e-Sign.

---

## Phase 1 — Auth Flow

### Page 1 — Splash Screen

| Function | Detail |
|---|---|
| App logo + loader animation | Shown on launch |
| Secure storage token check | Reads stored access/refresh token |
| Refresh token validation | Validates token with server |
| User role fetch | Determines which dashboard to open |

**Logic:**
- Token exists → Open dashboard by role
- Token missing → Onboarding Screen

---

### Page 2 — Onboarding

Three slides introducing the app:

1. Rent property intro
2. Buy/Sell intro
3. Direct owner contact intro

**Buttons:** Skip · Next · Get Started

Next → Role Selection

---

### Page 3 — Role Selection

Select one of four roles:

- `USER`
- `OWNER`
- `SELLER`
- `COMPANY`

Selected role is saved locally. Next → Register Page

---

### Page 4 — Register

**Input Fields:** name, email, phone, password, role

**Button:** Register

| API | Method | Result |
|---|---|---|
| `/api/auth/register` | `POST` | Account created, OTP sent → OTP Screen |

---

### Page 5 — OTP Verify

**Input:** OTP code

| Action | API | Method |
|---|---|---|
| Verify | `/api/auth/verify-otp` | `POST` |
| Resend | `/api/auth/resend-otp` | `POST` |

**Result:** access token (15 min) + refresh token (7 days) → Dashboard

---

### Page 6 — Login

**Input:** email, password

| Option | API | Method |
|---|---|---|
| Email/Password login | `/api/auth/login` | `POST` |
| Phone OTP | `/api/auth/send-otp` | `POST` |
| Google Login | `/api/auth/google` | `POST` |

---

## Phase 2 — User Dashboard

### Page 7 — Home Dashboard

| Feature | API | Method |
|---|---|---|
| Search (city / locality / apartment) | `/api/search` | `GET` |
| Search Suggestions | `/api/search/suggestions` | `GET` |

- **Rent / Buy Toggle:** RENT · SALE
- **Featured Listings:** premium, boosted, verified
- **Recommended Listings:** based on browsing history
- **City quick-select tiles:** shortcut to popular cities

---

### Page 8 — Search Results

Property cards display: image, title, price, location, save button.

**Actions:** Open detail · Save listing · Open filter · Map view

| Feature | Detail |
|---|---|
| Grid / List toggle | Switch between card layouts |
| Map split view | Mapbox map alongside listing cards |
| Sort dropdown | Sort by price, date, relevance |
| Active filters display | Shows applied filters as chips |
| Skeleton loaders | Shown while results fetch |

---

### Page 9 — Filter Page

**Filters:** budget, BHK, property type, furnishing, amenities, city, locality

| API | Method |
|---|---|
| `/api/search` | `GET` |

---

### Page 10 — Property Details

**Sections:** image gallery, floor plan viewer, owner info, nearby places, reviews, similar listings, price history chart

| Button | Action | API |
|---|---|---|
| Save Listing | Saves property | `POST /api/user/saved-listings` |
| Chat Now | Opens Chat Room | — |
| Call Owner | Phone call | — |
| WhatsApp | WhatsApp deep-link | — |
| Schedule Visit | Opens Visit Page | — |

**Premium Gate Logic:**

| Plan | Contact Access |
|---|---|
| Free | Limited — phone number hidden |
| Paid | Full reveal — phone + chat unlocked |

| API | Method | Purpose |
|---|---|---|
| `/api/listings/{id}/contact-reveal` | `POST` | Log contact reveal event |

---

### Page 11 — Saved Listings

| API | Method |
|---|---|
| `/api/user/saved-listings` | `GET` |

**Functions:** Remove saved property · Open property details · Compare up to 3 listings

---

### Page 12 — Compare Listings

**Function:** Side-by-side comparison of up to 3 saved properties

| Feature | Detail |
|---|---|
| Max properties | 3 at a time |
| Fields compared | price, BHK, size, amenities, location |
| Action | Open detail from compare view |

---

### Page 13 — Schedule Visit

**Input:** date, time, message

| API | Method | Result |
|---|---|---|
| `/api/user/site-visits` | `POST` | Owner notified |

---

### Page 14 — Profile

| API | Method | Purpose |
|---|---|---|
| `/api/user` | `GET` | Fetch profile |
| `/api/user/profile` | `PATCH` | Edit profile |
| `/api/user/kyc` | `POST` | Upload KYC docs |
| `/api/user/site-visits` | `GET` | Visit history |

**Functions:** Edit profile · Upload Aadhaar · Upload PAN · KYC verification · Visit history · Rent receipt download

---

### Page 15 — Saved Search Alerts

**Function:** User saves a search query; gets notified when new listings match

| Feature | Detail |
|---|---|
| Trigger | New listing matches saved filters |
| Alert types | Push notification + in-app |
| Price drop alert | Notified when saved listing price drops |

| API | Method | Purpose |
|---|---|---|
| `/api/user/saved-searches` | `POST` | Save a search |
| `/api/user/saved-searches` | `GET` | List saved searches |
| `/api/user/saved-searches/{id}` | `DELETE` | Remove saved search |

---

### Page 16 — Maintenance Requests

**Function:** Tenant raises maintenance issues for their rented property

**Input Fields:** issue type, description, photo upload

| API | Method | Purpose |
|---|---|---|
| `/api/user/maintenance` | `POST` | Raise ticket |
| `/api/user/maintenance` | `GET` | View ticket history |

**Statuses:** open · in-progress · resolved

---

### Page 17 — Rent Receipts

**Function:** Download monthly rent receipts for tax/record purposes

| API | Method | Purpose |
|---|---|---|
| `/api/user/rent-receipts` | `GET` | List all receipts |
| `/api/user/rent-receipts/{id}/download` | `GET` | Download PDF |

---

### Page 18 — Reviews

**Function:** User reviews owner and property after visit or deal

**Input Fields:** rating (1–5), review body

| API | Method | Purpose |
|---|---|---|
| `/api/user/reviews` | `POST` | Submit review |
| `/api/listings/{id}/reviews` | `GET` | View property reviews |

---

## Phase 3 — Owner Dashboard

### Page 19 — Owner Dashboard

| API | Method | Purpose |
|---|---|---|
| `/api/owner/listings` | `GET` | View listings |
| `/api/owner/interests` | `GET` | Interested buyers |
| `/api/owner/analytics` | `GET` | Analytics |

**Functions:** View listings · Interested buyers · Analytics · Boost listing

**Listing Status Chips:** draft · pending · approved · flagged · rented

---

### Page 20 — Add Listing Wizard

| Step | Input Fields | API |
|---|---|---|
| Step 1 — Basic | property type, BHK, floor, furnishing status, tenant preference | — |
| Step 2 — Price | rent, deposit, maintenance charges | — |
| Step 3 — Amenities | parking, lift, gym, pool, security | — |
| Step 4 — Media | photos, videos | `POST /api/owner/listings/{id}/media` |
| Step 5 — Map | Google Maps location pin | — |
| Step 6 — Publish | review + submit | `POST /api/owner/listings` |

**After Submit — Moderation Gate:**

| Outcome | Result |
|---|---|
| Approved | Listing goes live |
| Flagged | Sent to admin review queue |

**AI Features:**
- AI auto-description generated from property inputs
- Amenities checklist pre-filled by AI suggestion

---

### Page 21 — Manage Listing

| Function | Detail |
|---|---|
| Edit listing | Update any field |
| Mark as rented | Removes from active search |
| Renewal reminder | Cron triggers reminder before listing expires |
| Boost to featured | Opens Boost Listing page |

| API | Method | Purpose |
|---|---|---|
| `/api/owner/listings/{id}` | `PATCH` | Edit listing |
| `/api/owner/listings/{id}/status` | `PATCH` | Mark rented / unpublish |

---

### Page 22 — Seeker Interactions

**Function:** Owner manages all incoming interest from seekers

| Feature | Detail |
|---|---|
| Interest list | List of seekers who contacted |
| Chat with seeker | Opens chat room |
| Site visit confirm | Accept or decline visit request |
| Accept / Decline | Manage individual requests |

| API | Method | Purpose |
|---|---|---|
| `/api/owner/interests` | `GET` | All interest requests |
| `/api/owner/site-visits/{id}` | `PATCH` | Accept or decline |

---

### Page 23 — Deal Close

| Feature | Detail |
|---|---|
| Generate rent agreement | PDF created via document engine |
| e-Sign via DigiLocker | Both parties sign digitally |
| Token advance payment | Collect advance via payment gateway |
| Analytics: views → deals | Conversion funnel visible |

| API | Method | Purpose |
|---|---|---|
| `/api/documents/rent-agreement` | `POST` | Generate agreement |
| `/api/documents/{id}/sign` | `POST` | Trigger e-sign |
| `/api/payments` | `POST` | Initiate token advance |

---

### Page 24 — Boost Listing

| API | Method |
|---|---|
| `/api/owner/listings/{id}/boost` | `POST` |

**Plans:** Featured slot · Homepage placement · Boosted badge on card

---

## Phase 4 — Seller Dashboard

### Page 25 — Seller Dashboard

| API | Method | Purpose |
|---|---|---|
| `/api/seller/listings` | `GET` | Sale properties |
| `/api/seller/leads` | `GET` | Buyer leads |
| `/api/seller/analytics` | `GET` | Analytics |

**Functions:** Sale properties · Buyer leads · Analytics · Counter offer

---

### Page 26 — Add Sale Listing

| Step | Input Fields | API |
|---|---|---|
| Step 1 — Basic | property type, size (sqft), floor, BHK | — |
| Step 2 — Price | sale price, negotiable flag | — |
| Step 3 — Legal | ownership docs status, RERA ID, certificate of occupancy | — |
| Step 4 — Type | Direct resale · Under-construction · Auction listing | — |
| Step 5 — Media | photos, videos, floor plan, legal docs | `POST /api/seller/listings/{id}/media` |
| Step 6 — Publish | review + submit | `POST /api/seller/listings` |

**AI Feature:** AI price estimator based on location + size + type

---

### Page 27 — Manage Leads

| Feature | Detail |
|---|---|
| Buyer inquiries list | All inbound leads |
| Lead scoring | Hot / Warm / Cold tag |
| Chat + negotiate | Opens chat room with buyer |
| Counter-offer | Send new negotiated price |
| Transfer completion | Mark deal as complete |

| API | Method | Purpose |
|---|---|---|
| `/api/seller/leads` | `GET` | All leads |
| `/api/seller/leads/{id}/counter-offer` | `POST` | Send counter offer |
| `/api/seller/leads/{id}/status` | `PATCH` | Update lead status |

---

### Page 28 — Close Sale

| Feature | Detail |
|---|---|
| Sale agreement PDF | Generated by document engine |
| Token advance receipt | Payment confirmation doc |
| Document handover list | Checklist of docs to transfer |
| Transfer completion mark | Marks listing as sold |
| Delist property | Removes from active search |

| API | Method | Purpose |
|---|---|---|
| `/api/documents/sale-agreement` | `POST` | Generate sale agreement |
| `/api/seller/listings/{id}/status` | `PATCH` | Mark as sold / delist |

---

### Page 29 — Post-Sale

| Feature | Detail |
|---|---|
| Collect buyer review | Request review from buyer |
| Tax document archive | Store all deal documents |

| API | Method | Purpose |
|---|---|---|
| `/api/seller/leads/{id}/review-request` | `POST` | Request review |
| `/api/documents` | `GET` | List archived documents |

---

## Phase 5 — Company Dashboard

### Page 30 — Company Dashboard

| API | Method | Purpose |
|---|---|---|
| `/api/company` | `GET` | Company profile |
| `/api/company/projects` | `GET` | Projects list |
| `/api/company/leads` | `GET` | Leads |
| `/api/company/analytics` | `GET` | Analytics |

**Functions:** Profile · Projects · Leads · Analytics

---

### Page 31 — Company Onboarding

**Input Fields:** business name, RERA ID, KYC documents, brand logo

| Feature | Detail |
|---|---|
| Business KYC + RERA | Required for verified badge |
| Brand profile setup | Company name, logo, description |
| Team member invite | Add agents by email |
| Verified badge | Granted after admin approval |

| API | Method | Purpose |
|---|---|---|
| `/api/company/profile` | `POST` | Create company profile |
| `/api/company/agents` | `POST` | Invite agent |

---

### Page 32 — Project Management

| API | Method | Purpose |
|---|---|---|
| `/api/company/projects` | `POST` | Create project |
| `/api/company/projects/{id}/units` | `GET` | Unit inventory |
| `/api/company/projects/{id}/units` | `POST` | Add units |

**Input Fields:** project name, launch date, phase, floor-wise config, unit price

**Functions:** Create project · Unit inventory · Floor-wise units · Unit availability map · Launch phases

---

### Page 33 — Agent Management

| API | Method | Purpose |
|---|---|---|
| `/api/company/agents` | `GET` | List agents |
| `/api/company/agents` | `POST` | Add agent |
| `/api/company/agents/{id}/leads` | `POST` | Assign lead to agent |

**Functions:** Add agents · Assign leads · View agent performance · Follow-up task system · Lead source tracking

---

### Page 34 — Bulk Import

| API | Method | Purpose |
|---|---|---|
| `/api/company/bulk-import` | `POST` | CSV upload for mass listings |

**Functions:** CSV file picker · Bulk status update · Inventory tracker

---

### Page 35 — Campaign Manager

**Function:** Company promotes projects via featured slots and ad campaigns

| Feature | Detail |
|---|---|
| Featured project slots | Homepage premium placement |
| Homepage banner ads | Full-width banner promotion |
| Email campaign blast | Send to lead list |

| API | Method | Purpose |
|---|---|---|
| `/api/company/campaigns` | `POST` | Create campaign |
| `/api/company/campaigns` | `GET` | List campaigns |

---

## Phase 6 — Payments

### Page 36 — Subscription Plans

Plans: `FREE` · `BASIC` · `PRO` · `ENTERPRISE`

| Plan | Features |
|---|---|
| FREE | Limited contact reveals |
| BASIC | More reveals, basic analytics |
| PRO | Full reveals, priority listing |
| ENTERPRISE | All features + dedicated support |

| API | Method |
|---|---|
| `/api/payments/subscription` | `POST` |

---

### Page 37 — Payment Gateway

| API | Method | Purpose |
|---|---|---|
| `/api/payments` | `POST` | Initiate payment |
| `/api/payments/verify` | `POST` | Verify payment (webhook) |
| `/api/payments/history` | `GET` | Payment history |

**Gateways:** Razorpay (UPI / Card / Net Banking) · Stripe (international)

**Functions:** Invoice PDF download · Payment history · Refund management · Coupon / promo code input

---

## Phase 7 — Chat

### Page 38 — Chat List

| API | Method |
|---|---|
| `/api/chat/rooms` | `GET` |
| `/api/chat/rooms` | `POST` |

**Functions:** List all conversations · Unread count badge · Create new chat room linked to listing

---

### Page 39 — Chat Room

| API | Method | Purpose |
|---|---|---|
| `/api/chat/rooms/{roomId}` | `GET` | Room info |
| `/api/chat/rooms/{roomId}/messages` | `GET` | Fetch messages |
| `/api/chat/rooms/{roomId}/messages` | `POST` | Send message |
| `/api/chat/rooms/{roomId}/read` | `POST` | Mark as read |

**Functions:** Live messaging (Socket.io) · Image send · Read status ticks (sent / delivered / read) · Media preview · Block / Report user · FCM push when offline

---

## Phase 8 — Documents

### Page 40 — Documents

| API | Method | Purpose |
|---|---|---|
| `/api/documents/rent-agreement` | `POST` | Generate rent agreement |
| `/api/documents/sale-agreement` | `POST` | Generate sale agreement |
| `/api/documents` | `GET` | List all documents |
| `/api/documents/{id}/download` | `GET` | Download PDF |
| `/api/documents/{id}/sign` | `POST` | Trigger e-sign |

**Functions:**
- Rent agreement PDF generation
- Sale agreement PDF generation
- e-Stamp integration
- DigiLocker e-Sign (both parties sign digitally)
- Monthly rent receipt auto-generation (server cron)
- Document stored on VPS + reference saved in DB

---

## Phase 9 — Notifications

### Page 41 — Notifications

| API | Method | Purpose |
|---|---|---|
| `/api/notifications` | `GET` | Fetch all notifications | 
| `/api/notifications/{id}/read` | `POST` | Mark one as read |
| `/api/notifications/read-all` | `POST` | Mark all as read |

**Channels:**

| Channel | Technology |
|---|---|
| Email | Nodemailer + SMTP |
| SMS | Twilio |
| Push | Firebase FCM |
| In-app | Redis pub/sub |
| WhatsApp | Meta API |

**Types:** Lead alerts · Payment updates · Chat alerts · Approval updates · Price drop alerts · Visit confirmations · Listing renewal reminders

---

## Phase 10 — Admin Dashboard

### Page 42 — Admin Dashboard

| API | Method | Purpose |
|---|---|---|
| `/api/admin/stats` | `GET` | Platform statistics |
| `/api/admin/users` | `GET` | All users list |
| `/api/admin/users/{id}` | `PATCH` | Edit user |
| `/api/admin/users/{id}/status` | `POST` | Enable/disable user |
| `/api/admin/moderation` | `GET` | Content moderation queue |
| `/api/admin/reports` | `GET` | Reports |
| `/api/admin/feature-flags` | `GET` | Feature flags list |
| `/api/admin/feature-flags/{key}` | `PATCH` | Toggle feature flag |
| `/api/admin/audit-logs` | `GET` | Audit logs |

**Dashboard Overview:**

| Widget | Detail |
|---|---|
| Total listings / users | Live platform count |
| Revenue MRR snapshot | Monthly recurring revenue |
| Active chats + reports | Real-time counts |
| Server health widget | CPU / memory / uptime |

---

### Page 43 — Listing Moderation

**Function:** Admin reviews flagged or pending listings before they go live

| Action | Detail |
|---|---|
| Approve | Listing goes live |
| Reject | Listing removed with reason |
| Edit | Admin can fix listing before approval |
| Duplicate detection | System flags duplicate entries |
| Fraud flag review | Review reported fraudulent listings |
| Image quality check | Verify uploaded images meet standards |

| API | Method | Purpose |
|---|---|---|
| `/api/admin/moderation/{id}/approve` | `POST` | Approve listing |
| `/api/admin/moderation/{id}/reject` | `POST` | Reject listing |

---

### Page 44 — User Management

| Feature | Detail |
|---|---|
| KYC review + verify | Admin approves Aadhaar / PAN / business docs |
| Ban / Suspend / Warn | Tiered user action |
| Role assignment | Change user role |
| Activity audit log | Full history of user actions |

| API | Method | Purpose |
|---|---|---|
| `/api/admin/users/{id}` | `PATCH` | Edit user details |
| `/api/admin/users/{id}/status` | `POST` | Ban / suspend / activate |
| `/api/admin/users/{id}/kyc` | `PATCH` | Approve or reject KYC |

---

### Page 45 — Reports & Disputes

| Feature | Detail |
|---|---|
| Spam / fraud tickets | User-reported issues |
| Owner–user disputes | Conflict resolution queue |
| SLA breach escalation | Tickets past SLA are auto-escalated |

| API | Method | Purpose |
|---|---|---|
| `/api/admin/reports` | `GET` | All reports |
| `/api/admin/reports/{id}` | `PATCH` | Update report status |
| `/api/admin/disputes/{id}` | `PATCH` | Resolve dispute |

---

### Page 46 — Plan & Revenue

| Feature | Detail |
|---|---|
| Subscription override | Admin manually changes user plan |
| Manual refund | Trigger refund for a payment |
| Plan tier config | Edit plan features and pricing |
| Coupon / promo codes | Create discount codes |

| API | Method | Purpose |
|---|---|---|
| `/api/admin/subscriptions/{id}` | `PATCH` | Override plan |
| `/api/admin/payments/{id}/refund` | `POST` | Issue refund |
| `/api/admin/coupons` | `POST` | Create coupon |
| `/api/admin/coupons` | `GET` | List coupons |

---

### Page 47 — System Controls

| Feature | Detail |
|---|---|
| Search boost weights | Adjust ranking factors for search |
| Email template editor | Edit transactional email templates |
| Cron job monitor | View scheduled job status |
| Feature flags toggle | Enable / disable features per environment |

| API | Method | Purpose |
|---|---|---|
| `/api/admin/feature-flags/{key}` | `PATCH` | Toggle feature flag |
| `/api/admin/search-config` | `PATCH` | Update boost weights |
| `/api/admin/cron-jobs` | `GET` | Monitor scheduled jobs |

---

## Database Schema

### PostgreSQL — Core Tables

| Table | Fields |
|---|---|
| `users` | id · role · email · phone · plan · kyc_status · is_verified |
| `listings` | id · owner_id · type · purpose · bhk · rent · price · status · geo_point |
| `listing_media` | id · listing_id · file_path · type · order |
| `companies` | id · user_id · name · rera_id · verified · plan |
| `projects` | id · company_id · name · launch_date · phase · status |
| `subscriptions` | id · user_id · plan · gateway · status · expires_at |
| `contact_events` | id · seeker_id · listing_id · revealed_at · type |
| `site_visits` | id · listing_id · seeker_id · scheduled_at · status |
| `agreements` | id · listing_id · pdf_path · signed_owner · signed_seeker |
| `payments` | id · user_id · amount · gateway · status · invoice_path |
| `reviews` | id · reviewer_id · reviewee_id · listing_id · rating · body |
| `saved_listings` | user_id · listing_id · created_at |
| `leads` | id · listing_id · buyer_id · status · score · assigned_to |
| `notifications` | id · user_id · type · payload · read_at · channel |
| `moderation_queue` | id · entity_type · entity_id · status · reviewer_id |
| `audit_logs` | id · user_id · action · entity · old_val · new_val · ts |
| `maintenance_tickets` | id · listing_id · raised_by · status · resolved_at |
| `feature_flags` | id · key · value · enabled · updated_by |

### MongoDB Collections

| Collection | Purpose |
|---|---|
| `messages` | Chat messages per room |
| `activity_logs` | User activity stream |
| `campaigns` | Company campaign data |

---

## Getting Started

```bash
flutter pub get
flutter run
```

For Flutter documentation, visit [flutter.dev](https://flutter.dev).
