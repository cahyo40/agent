---
name: library-system-developer
description: "Expert library management system development including catalog management, borrowing systems, member management, digital libraries, and multi-platform solutions"
---

# Library System Developer

## Overview

This skill transforms you into an **Expert Library System Developer** with extensive experience building library management systems across web, mobile, and desktop platforms. You will master catalog management, circulation systems, member portals, and digital library integration.

## When to Use This Skill

- Use when building library management systems
- Use when implementing book catalog and search
- Use when designing borrowing/return workflows
- Use when integrating with digital resources (e-books, journals)
- Use when building multi-platform library solutions

---

## Part 1: Library System Architecture

### 1.1 Core Modules

```
┌─────────────────────────────────────────────────────────────────────┐
│                    Library Management System                         │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌────────────┐ │
│  │  Catalog    │  │ Circulation │  │   Member    │  │  Reports   │ │
│  │ Management  │  │   System    │  │   Portal    │  │ Analytics  │ │
│  └─────────────┘  └─────────────┘  └─────────────┘  └────────────┘ │
│                                                                      │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌────────────┐ │
│  │   OPAC      │  │   Digital   │  │    Fine     │  │ Inventory  │ │
│  │  (Search)   │  │   Library   │  │ Management  │  │   & Stock  │ │
│  └─────────────┘  └─────────────┘  └─────────────┘  └────────────┘ │
│                                                                      │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐                 │
│  │  Barcode/   │  │   RFID      │  │   API       │                 │
│  │  QR Code    │  │ Integration │  │ Integration │                 │
│  └─────────────┘  └─────────────┘  └─────────────┘                 │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

### 1.2 Key Terminology

| Term | Description |
|------|-------------|
| **OPAC** | Online Public Access Catalog - user-facing search |
| **ILS** | Integrated Library System - full management suite |
| **MARC** | Machine-Readable Cataloging - bibliographic standard |
| **ISBN** | International Standard Book Number |
| **DDC** | Dewey Decimal Classification |
| **LCC** | Library of Congress Classification |
| **Circulation** | Borrowing, returning, reserving items |
| **Patron** | Library member/user |

### 1.3 System Flow

```
Member Journey:
┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐
│  Search  │───►│  Reserve │───►│  Borrow  │───►│  Return  │
│  Catalog │    │   Book   │    │   Book   │    │   Book   │
└──────────┘    └──────────┘    └──────────┘    └──────────┘
                                      │              │
                                      ▼              ▼
                               ┌──────────┐   ┌──────────┐
                               │  Renew   │   │   Fine   │
                               │   Book   │   │ (if late)│
                               └──────────┘   └──────────┘
```

---

## Part 2: Database Schema

### 2.1 Core Tables

```sql
-- Books table
CREATE TABLE books (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    isbn VARCHAR(17) UNIQUE,
    title VARCHAR(500) NOT NULL,
    subtitle VARCHAR(500),
    edition VARCHAR(50),
    publisher VARCHAR(200),
    publish_year INTEGER,
    language VARCHAR(50) DEFAULT 'Indonesian',
    page_count INTEGER,
    description TEXT,
    cover_image_url TEXT,
    classification_code VARCHAR(50),  -- DDC or LCC
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Authors table (many-to-many with books)
CREATE TABLE authors (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(200) NOT NULL,
    bio TEXT,
    birth_year INTEGER,
    death_year INTEGER
);

CREATE TABLE book_authors (
    book_id UUID REFERENCES books(id) ON DELETE CASCADE,
    author_id UUID REFERENCES authors(id) ON DELETE CASCADE,
    role VARCHAR(50) DEFAULT 'author', -- author, editor, translator
    PRIMARY KEY (book_id, author_id)
);

-- Categories/Subjects
CREATE TABLE categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    parent_id UUID REFERENCES categories(id),
    ddc_code VARCHAR(20),
    description TEXT
);

CREATE TABLE book_categories (
    book_id UUID REFERENCES books(id) ON DELETE CASCADE,
    category_id UUID REFERENCES categories(id) ON DELETE CASCADE,
    PRIMARY KEY (book_id, category_id)
);

-- Book copies (physical items)
CREATE TABLE book_copies (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    book_id UUID REFERENCES books(id) ON DELETE CASCADE,
    barcode VARCHAR(50) UNIQUE NOT NULL,
    rfid_tag VARCHAR(100) UNIQUE,
    location VARCHAR(100),  -- e.g., "Shelf A-12"
    branch_id UUID REFERENCES branches(id),
    status VARCHAR(20) DEFAULT 'available',
    condition VARCHAR(20) DEFAULT 'good',
    acquisition_date DATE,
    acquisition_source VARCHAR(100),  -- purchase, donation
    price DECIMAL(12, 2),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Status: available, borrowed, reserved, maintenance, lost, damaged, retired
CREATE INDEX idx_book_copies_status ON book_copies(status);
CREATE INDEX idx_book_copies_barcode ON book_copies(barcode);
```

### 2.2 Member & Circulation Tables

```sql
-- Members table
CREATE TABLE members (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    member_number VARCHAR(50) UNIQUE NOT NULL,
    membership_type VARCHAR(50) NOT NULL,  -- student, teacher, public
    name VARCHAR(200) NOT NULL,
    email VARCHAR(255) UNIQUE,
    phone VARCHAR(20),
    address TEXT,
    id_card_number VARCHAR(50),  -- KTP, NIM, NIP
    photo_url TEXT,
    date_of_birth DATE,
    registration_date DATE DEFAULT CURRENT_DATE,
    expiry_date DATE,
    status VARCHAR(20) DEFAULT 'active',  -- active, suspended, expired
    max_loans INTEGER DEFAULT 3,
    max_loan_days INTEGER DEFAULT 14,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Loans (borrowing records)
CREATE TABLE loans (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    member_id UUID REFERENCES members(id),
    copy_id UUID REFERENCES book_copies(id),
    loan_date DATE NOT NULL DEFAULT CURRENT_DATE,
    due_date DATE NOT NULL,
    return_date DATE,
    renewed_count INTEGER DEFAULT 0,
    status VARCHAR(20) DEFAULT 'active',  -- active, returned, overdue, lost
    loaned_by UUID REFERENCES staff(id),
    returned_to UUID REFERENCES staff(id),
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_loans_member ON loans(member_id);
CREATE INDEX idx_loans_status ON loans(status);
CREATE INDEX idx_loans_due_date ON loans(due_date);

-- Reservations
CREATE TABLE reservations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    member_id UUID REFERENCES members(id),
    book_id UUID REFERENCES books(id),
    reservation_date TIMESTAMPTZ DEFAULT NOW(),
    expiry_date TIMESTAMPTZ,
    status VARCHAR(20) DEFAULT 'pending',  -- pending, fulfilled, cancelled, expired
    notified_at TIMESTAMPTZ,
    fulfilled_loan_id UUID REFERENCES loans(id),
    queue_position INTEGER
);

-- Fines
CREATE TABLE fines (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    loan_id UUID REFERENCES loans(id),
    member_id UUID REFERENCES members(id),
    amount DECIMAL(12, 2) NOT NULL,
    reason VARCHAR(50) NOT NULL,  -- overdue, lost, damaged
    days_overdue INTEGER,
    paid_amount DECIMAL(12, 2) DEFAULT 0,
    paid_at TIMESTAMPTZ,
    status VARCHAR(20) DEFAULT 'unpaid',  -- unpaid, partial, paid, waived
    created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### 2.3 Digital Library Tables

```sql
-- E-books and digital resources
CREATE TABLE digital_resources (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    book_id UUID REFERENCES books(id),
    resource_type VARCHAR(50) NOT NULL,  -- ebook, audiobook, journal, thesis
    file_format VARCHAR(20),  -- pdf, epub, mp3
    file_url TEXT,
    file_size_bytes BIGINT,
    access_type VARCHAR(20) DEFAULT 'members',  -- public, members, restricted
    max_concurrent_users INTEGER DEFAULT 5,
    drm_protected BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Digital loans
CREATE TABLE digital_loans (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    member_id UUID REFERENCES members(id),
    resource_id UUID REFERENCES digital_resources(id),
    start_date TIMESTAMPTZ DEFAULT NOW(),
    end_date TIMESTAMPTZ NOT NULL,
    status VARCHAR(20) DEFAULT 'active',
    download_count INTEGER DEFAULT 0,
    last_accessed_at TIMESTAMPTZ
);
```

---

## Part 3: Core Business Logic

### 3.1 Borrowing Service

```typescript
// services/loan.service.ts
interface LoanResult {
  success: boolean;
  loan?: Loan;
  error?: string;
}

class LoanService {
  constructor(
    private loanRepo: LoanRepository,
    private memberRepo: MemberRepository,
    private copyRepo: BookCopyRepository,
    private fineService: FineService,
    private notificationService: NotificationService
  ) {}

  async borrowBook(memberId: string, copyBarcode: string): Promise<LoanResult> {
    // 1. Validate member
    const member = await this.memberRepo.findById(memberId);
    if (!member) {
      return { success: false, error: 'Anggota tidak ditemukan' };
    }
    
    if (member.status !== 'active') {
      return { success: false, error: 'Keanggotaan tidak aktif' };
    }
    
    if (new Date() > member.expiryDate) {
      return { success: false, error: 'Keanggotaan sudah kadaluarsa' };
    }

    // 2. Check for unpaid fines
    const unpaidFines = await this.fineService.getUnpaidTotal(memberId);
    if (unpaidFines > 50000) { // Max Rp 50.000 unpaid fines
      return { success: false, error: 'Ada denda belum dibayar' };
    }

    // 3. Check loan limit
    const activeLoans = await this.loanRepo.countActive(memberId);
    if (activeLoans >= member.maxLoans) {
      return { 
        success: false, 
        error: `Batas peminjaman tercapai (${member.maxLoans} buku)` 
      };
    }

    // 4. Validate book copy
    const copy = await this.copyRepo.findByBarcode(copyBarcode);
    if (!copy) {
      return { success: false, error: 'Buku tidak ditemukan' };
    }
    
    if (copy.status !== 'available') {
      return { success: false, error: 'Buku tidak tersedia' };
    }

    // 5. Check if same book already borrowed
    const existingLoan = await this.loanRepo.findActiveByMemberAndBook(
      memberId, 
      copy.bookId
    );
    if (existingLoan) {
      return { success: false, error: 'Anda sudah meminjam buku ini' };
    }

    // 6. Create loan
    const dueDate = this.calculateDueDate(member.maxLoanDays);
    
    const loan = await this.loanRepo.create({
      memberId,
      copyId: copy.id,
      loanDate: new Date(),
      dueDate,
      status: 'active',
    });

    // 7. Update copy status
    await this.copyRepo.updateStatus(copy.id, 'borrowed');

    // 8. Send notification
    await this.notificationService.sendLoanConfirmation(member, loan, copy);

    return { success: true, loan };
  }

  async returnBook(copyBarcode: string): Promise<LoanResult> {
    const copy = await this.copyRepo.findByBarcode(copyBarcode);
    if (!copy) {
      return { success: false, error: 'Buku tidak ditemukan' };
    }

    const loan = await this.loanRepo.findActiveByCopy(copy.id);
    if (!loan) {
      return { success: false, error: 'Tidak ada peminjaman aktif' };
    }

    const returnDate = new Date();
    
    // Calculate fine if overdue
    if (returnDate > loan.dueDate) {
      const daysOverdue = this.calculateDaysOverdue(loan.dueDate, returnDate);
      await this.fineService.createOverdueFine(loan, daysOverdue);
    }

    // Update loan
    await this.loanRepo.update(loan.id, {
      returnDate,
      status: 'returned',
    });

    // Update copy status
    await this.copyRepo.updateStatus(copy.id, 'available');

    // Check for reservations
    await this.processNextReservation(copy.bookId);

    return { success: true, loan };
  }

  async renewLoan(loanId: string): Promise<LoanResult> {
    const loan = await this.loanRepo.findById(loanId);
    if (!loan) {
      return { success: false, error: 'Peminjaman tidak ditemukan' };
    }

    if (loan.status !== 'active') {
      return { success: false, error: 'Peminjaman tidak aktif' };
    }

    // Check renewal limit (max 2 times)
    if (loan.renewedCount >= 2) {
      return { success: false, error: 'Batas perpanjangan tercapai' };
    }

    // Check for reservations on this book
    const hasReservation = await this.reservationRepo.hasActiveReservation(
      loan.copy.bookId
    );
    if (hasReservation) {
      return { success: false, error: 'Ada reservasi untuk buku ini' };
    }

    // Extend due date
    const member = await this.memberRepo.findById(loan.memberId);
    const newDueDate = this.calculateDueDate(member.maxLoanDays, loan.dueDate);

    await this.loanRepo.update(loanId, {
      dueDate: newDueDate,
      renewedCount: loan.renewedCount + 1,
    });

    return { success: true, loan: { ...loan, dueDate: newDueDate } };
  }

  private calculateDueDate(days: number, fromDate?: Date): Date {
    const date = fromDate ? new Date(fromDate) : new Date();
    date.setDate(date.getDate() + days);
    return date;
  }

  private calculateDaysOverdue(dueDate: Date, returnDate: Date): number {
    const diff = returnDate.getTime() - dueDate.getTime();
    return Math.ceil(diff / (1000 * 60 * 60 * 24));
  }
}
```

### 3.2 Catalog Search (OPAC)

```typescript
// services/catalog.service.ts
interface SearchParams {
  query?: string;
  title?: string;
  author?: string;
  isbn?: string;
  category?: string;
  year?: number;
  language?: string;
  availability?: 'all' | 'available' | 'digital';
  page?: number;
  limit?: number;
  sortBy?: 'relevance' | 'title' | 'year' | 'author';
}

interface SearchResult {
  books: BookWithDetails[];
  total: number;
  page: number;
  totalPages: number;
  facets: SearchFacets;
}

class CatalogService {
  async search(params: SearchParams): Promise<SearchResult> {
    const {
      query,
      page = 1,
      limit = 20,
      sortBy = 'relevance',
      ...filters
    } = params;

    // Build full-text search query
    let queryBuilder = this.db
      .selectFrom('books')
      .leftJoin('book_authors', 'books.id', 'book_authors.book_id')
      .leftJoin('authors', 'book_authors.author_id', 'authors.id')
      .leftJoin('book_categories', 'books.id', 'book_categories.book_id')
      .leftJoin('categories', 'book_categories.category_id', 'categories.id');

    // Full-text search across title, author, description
    if (query) {
      queryBuilder = queryBuilder.where((eb) =>
        eb.or([
          eb('books.title', 'ilike', `%${query}%`),
          eb('authors.name', 'ilike', `%${query}%`),
          eb('books.description', 'ilike', `%${query}%`),
          eb('books.isbn', '=', query),
        ])
      );
    }

    // Apply filters
    if (filters.title) {
      queryBuilder = queryBuilder.where('books.title', 'ilike', `%${filters.title}%`);
    }
    if (filters.author) {
      queryBuilder = queryBuilder.where('authors.name', 'ilike', `%${filters.author}%`);
    }
    if (filters.isbn) {
      queryBuilder = queryBuilder.where('books.isbn', '=', filters.isbn);
    }
    if (filters.category) {
      queryBuilder = queryBuilder.where('categories.id', '=', filters.category);
    }
    if (filters.year) {
      queryBuilder = queryBuilder.where('books.publish_year', '=', filters.year);
    }
    if (filters.language) {
      queryBuilder = queryBuilder.where('books.language', '=', filters.language);
    }

    // Get total count
    const countResult = await queryBuilder.select(eb => eb.fn.count('books.id').as('total')).executeTakeFirst();
    const total = Number(countResult?.total || 0);

    // Apply sorting
    switch (sortBy) {
      case 'title':
        queryBuilder = queryBuilder.orderBy('books.title', 'asc');
        break;
      case 'year':
        queryBuilder = queryBuilder.orderBy('books.publish_year', 'desc');
        break;
      case 'author':
        queryBuilder = queryBuilder.orderBy('authors.name', 'asc');
        break;
      default:
        // Relevance (for full-text search)
        queryBuilder = queryBuilder.orderBy('books.created_at', 'desc');
    }

    // Pagination
    const offset = (page - 1) * limit;
    const books = await queryBuilder
      .selectAll('books')
      .limit(limit)
      .offset(offset)
      .execute();

    // Enrich with availability
    const enrichedBooks = await this.enrichWithAvailability(books);

    // Get facets for filtering UI
    const facets = await this.getFacets(params);

    return {
      books: enrichedBooks,
      total,
      page,
      totalPages: Math.ceil(total / limit),
      facets,
    };
  }

  private async enrichWithAvailability(books: Book[]): Promise<BookWithDetails[]> {
    return Promise.all(
      books.map(async (book) => {
        const copies = await this.copyRepo.findByBookId(book.id);
        const available = copies.filter(c => c.status === 'available').length;
        
        return {
          ...book,
          totalCopies: copies.length,
          availableCopies: available,
          isAvailable: available > 0,
        };
      })
    );
  }
}
```

### 3.3 Fine Calculation

```typescript
// services/fine.service.ts
interface FineConfig {
  dailyRate: number;        // Denda per hari
  maxFinePerItem: number;   // Maksimal denda per item
  lostItemMultiplier: number; // Pengganti buku hilang
  gracePeriodDays: number;  // Masa tenggang
}

class FineService {
  private config: FineConfig = {
    dailyRate: 1000,         // Rp 1.000 per hari
    maxFinePerItem: 50000,   // Maks Rp 50.000
    lostItemMultiplier: 2,   // 2x harga buku
    gracePeriodDays: 0,      // Tidak ada grace period
  };

  async createOverdueFine(loan: Loan, daysOverdue: number): Promise<Fine> {
    const effectiveDays = Math.max(0, daysOverdue - this.config.gracePeriodDays);
    
    if (effectiveDays <= 0) return null;

    let amount = effectiveDays * this.config.dailyRate;
    amount = Math.min(amount, this.config.maxFinePerItem);

    return this.fineRepo.create({
      loanId: loan.id,
      memberId: loan.memberId,
      amount,
      reason: 'overdue',
      daysOverdue: effectiveDays,
      status: 'unpaid',
    });
  }

  async createLostItemFine(loan: Loan): Promise<Fine> {
    const copy = await this.copyRepo.findById(loan.copyId);
    const book = await this.bookRepo.findById(copy.bookId);
    
    // Lost item: book price × multiplier, or default amount
    const amount = copy.price 
      ? copy.price * this.config.lostItemMultiplier
      : 100000; // Default Rp 100.000

    return this.fineRepo.create({
      loanId: loan.id,
      memberId: loan.memberId,
      amount,
      reason: 'lost',
      status: 'unpaid',
    });
  }

  async payFine(fineId: string, amount: number): Promise<Fine> {
    const fine = await this.fineRepo.findById(fineId);
    
    const newPaidAmount = fine.paidAmount + amount;
    const status = newPaidAmount >= fine.amount ? 'paid' : 'partial';

    return this.fineRepo.update(fineId, {
      paidAmount: newPaidAmount,
      paidAt: status === 'paid' ? new Date() : null,
      status,
    });
  }
}
```

---

## Part 4: Multi-Platform Development

### 4.1 Platform-Specific Features

| Platform | Key Features |
|----------|--------------|
| **Web (Admin)** | Full catalog management, reports, member management |
| **Web (OPAC)** | Search, reservations, account, e-resources |
| **Mobile (Member)** | Barcode scan, search, loans, notifications |
| **Mobile (Staff)** | Quick checkout/return, inventory scan |
| **Desktop** | Offline capability, barcode printing, bulk operations |
| **Kiosk** | Self-checkout, self-return, catalog search |

### 4.2 Mobile App Features

```dart
// Flutter: Member App
class LibraryMemberApp {
  // Core features
  - Catalog search with filters
  - Barcode scanner for quick lookup
  - View current loans and history
  - Renew books
  - Reserve books
  - View and pay fines
  - Digital library access
  - Push notifications (due dates, reservations)
  - Member card (QR Code)
  
  // Offline features
  - Cached search results
  - Downloaded e-books
  - Barcode scanning
}

// Flutter: Staff App
class LibraryStaffApp {
  // Core features
  - Quick checkout via barcode scan
  - Quick return via barcode scan
  - Member lookup (by card, name, phone)
  - View member loans and fines
  - Process fine payments
  - Inventory scanning
  - Notifications for overdue items
}
```

### 4.3 Self-Service Kiosk

```typescript
// Kiosk features
interface KioskModule {
  selfCheckout: {
    scanMemberCard(): Member;
    scanBookBarcode(): BookCopy;
    confirmCheckout(): Loan;
    printReceipt(): void;
  };
  
  selfReturn: {
    scanBookBarcode(): BookCopy;
    processReturn(): {returned: boolean; fine?: number};
    printReceipt(): void;
  };
  
  catalogSearch: {
    searchBooks(query: string): Book[];
    viewBookDetails(id: string): BookDetails;
    checkAvailability(id: string): CopyAvailability[];
    reserveBook(bookId: string, memberId: string): Reservation;
  };
  
  accountServices: {
    viewLoans(memberId: string): Loan[];
    renewBook(loanId: string): RenewalResult;
    viewFines(memberId: string): Fine[];
    payFines(fineIds: string[]): PaymentResult;
  };
}
```

---

## Part 5: Integrations

### 5.1 Barcode/RFID Integration

```typescript
// Barcode scanning
interface BarcodeService {
  // Generate barcode for new books
  generateBarcode(prefix: string): string;
  
  // Scan barcode
  onScan(barcode: string): Promise<{
    type: 'book' | 'member' | 'unknown';
    data: BookCopy | Member | null;
  }>;
  
  // Print barcode labels
  printLabels(copies: BookCopy[], printer: string): Promise<void>;
}

// RFID integration
interface RFIDService {
  // Read single tag
  readTag(): Promise<string>;
  
  // Read multiple tags (for bulk return)
  readMultipleTags(timeout: number): Promise<string[]>;
  
  // Write tag
  writeTag(tagId: string, data: string): Promise<boolean>;
  
  // Anti-theft gate integration
  checkGateSensor(): Observable<{
    type: 'entry' | 'exit';
    tags: string[];
    hasUnauthorized: boolean;
  }>;
}
```

### 5.2 External APIs

```typescript
// ISBN lookup (e.g., Google Books, Open Library)
interface ISBNLookupService {
  async lookupISBN(isbn: string): Promise<BookMetadata | null> {
    // Try Google Books first
    const googleResult = await this.googleBooksApi.lookup(isbn);
    if (googleResult) return this.mapGoogleBook(googleResult);
    
    // Fallback to Open Library
    const openLibResult = await this.openLibraryApi.lookup(isbn);
    if (openLibResult) return this.mapOpenLibBook(openLibResult);
    
    return null;
  }
}

// Digital library integration (e.g., OverDrive, Libby)
interface DigitalLibraryIntegration {
  searchEBooks(query: string): Promise<DigitalResource[]>;
  borrowEBook(resourceId: string, memberId: string): Promise<DigitalLoan>;
  returnEBook(loanId: string): Promise<void>;
  downloadEBook(loanId: string): Promise<ReadableStream>;
}
```

---

## Part 6: Reports & Analytics

### 6.1 Key Reports

| Report | Description |
|--------|-------------|
| **Circulation Stats** | Daily/monthly loans, returns, renewals |
| **Popular Books** | Most borrowed, most reserved |
| **Overdue Report** | List of overdue items with contact info |
| **Fine Report** | Outstanding fines, paid fines, waivers |
| **Collection Analysis** | Books by category, age, condition |
| **Member Activity** | Active members, new registrations |
| **Inventory Status** | Missing, lost, damaged items |

### 6.2 SQL Report Examples

```sql
-- Most borrowed books this month
SELECT 
    b.title,
    a.name as author,
    COUNT(l.id) as loan_count
FROM loans l
JOIN book_copies bc ON l.copy_id = bc.id
JOIN books b ON bc.book_id = b.id
LEFT JOIN book_authors ba ON b.id = ba.book_id
LEFT JOIN authors a ON ba.author_id = a.id
WHERE l.loan_date >= DATE_TRUNC('month', CURRENT_DATE)
GROUP BY b.id, b.title, a.name
ORDER BY loan_count DESC
LIMIT 20;

-- Overdue items with member contact
SELECT 
    m.name as member_name,
    m.email,
    m.phone,
    b.title,
    l.due_date,
    CURRENT_DATE - l.due_date as days_overdue
FROM loans l
JOIN members m ON l.member_id = m.id
JOIN book_copies bc ON l.copy_id = bc.id
JOIN books b ON bc.book_id = b.id
WHERE l.status = 'active' 
  AND l.due_date < CURRENT_DATE
ORDER BY days_overdue DESC;

-- Collection utilization
SELECT 
    c.name as category,
    COUNT(DISTINCT b.id) as total_books,
    COUNT(DISTINCT bc.id) as total_copies,
    COUNT(DISTINCT l.id) as total_loans_year,
    ROUND(COUNT(DISTINCT l.id)::numeric / NULLIF(COUNT(DISTINCT bc.id), 0), 2) as utilization_rate
FROM categories c
LEFT JOIN book_categories bcat ON c.id = bcat.category_id
LEFT JOIN books b ON bcat.book_id = b.id
LEFT JOIN book_copies bc ON b.id = bc.book_id
LEFT JOIN loans l ON bc.id = l.copy_id 
    AND l.loan_date >= CURRENT_DATE - INTERVAL '1 year'
GROUP BY c.id, c.name
ORDER BY utilization_rate DESC;
```

---

## Part 7: Best Practices

### ✅ Do This

- ✅ Use ISBN for book identification when available
- ✅ Implement barcode/RFID for efficient circulation
- ✅ Set up automated overdue notifications
- ✅ Provide self-service options (kiosk, mobile)
- ✅ Regular inventory audits
- ✅ Backup bibliographic data regularly

### ❌ Avoid This

- ❌ Don't allow borrowing without member verification
- ❌ Don't skip fine calculation for any overdue
- ❌ Don't delete loan history (archive instead)
- ❌ Don't allow unlimited renewals without checking reservations
- ❌ Don't ignore low-circulation items in collection development

---

## Related Skills

- `@senior-react-developer` - Web OPAC development
- `@senior-flutter-developer` - Mobile apps
- `@postgresql-specialist` - Database optimization
- `@senior-ui-ux-designer` - Library UX design
