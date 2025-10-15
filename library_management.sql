create database smartlibrarydb;
use smartlibrarydb;

create table authors (
    author_id int primary key auto_increment,
    name varchar(100) not null,
    email varchar(100) unique
);

create table members (
    member_id int primary key auto_increment,
    name varchar(100) not null,
    email varchar(100) unique,
    phone_number varchar(15),
    membership_date date not null
);

create table books (
    book_id int primary key auto_increment,
    title varchar(255) not null,
    author_id int not null,
    category varchar(50),
    isbn varchar(20) unique,
    published_date date,
    price decimal(10, 2),
    available_copies int not null default 1,
    foreign key (author_id) references authors(author_id)
);

create table transactions (
    transaction_id int primary key auto_increment,
    member_id int not null,
    book_id int not null,
    borrow_date date not null,
    return_date date,
    fine_amount decimal(5, 2) default 0.00,
    foreign key (member_id) references members(member_id),
    foreign key (book_id) references books(book_id)
);

insert into authors (name, email) values
('Stephen King', 'sk@example.com'),
('Arundhati Roy', 'aroy@india.com'),
('Isaac Asimov', 'ia@example.com'),
('Ruskin Bond', 'rbond@india.com');

insert into members (name, email, phone_number, membership_date) values
('Alice Smith', 'alice@test.com', '1234567890', '2021-05-10'),
('Rohan Sharma', 'rohan@test.com', '0987654321', '2022-11-20'),
('Charlie Brown', 'charlie@test.com', '1122334455', '2023-01-15'),
('Priya Singh', 'priya@test.com', '5566778899', '2019-08-01');

insert into books (title, author_id, category, isbn, published_date, price, available_copies) values
('the stand', 1, 'horror', '978-0385199577', '1978-10-03', 450.00, 5),
('the god of small things', 2, 'fiction', '978-0679781123', '1997-01-01', 350.50, 2),
('i, robot', 3, 'science', '978-0553293357', '1950-12-02', 250.75, 10),
('the dark tower', 1, 'fantasy', '978-1501166649', '1982-01-01', 650.99, 3),
('harry potter 1', 1, 'fantasy', '978-0747532743', '1997-06-26', 499.99, 1),
('brave new world', 3, 'science', '978-0060850524', '1932-01-01', 520.00, 0),
('delhi is not far', 4, 'travel', '978-0143030310', '1994-01-01', 550.00, 4),
('the martian', 3, 'science', '978-0804139024', '2011-02-15', 550.00, 4),
('project hail mary', 3, 'science', '978-0593135204', '2021-05-04', 700.00, 6);

insert into transactions (member_id, book_id, borrow_date, return_date, fine_amount) values
(1, 4, '2024-03-01', '2024-03-15', 0.00),
(2, 2, '2024-04-01', '2024-04-10', 0.00),
(3, 1, '2024-04-15', '2024-04-20', 5.00),
(1, 5, '2024-05-01', '2024-05-25', 10.00),
(2, 7, '2024-01-01', '2024-01-10', 0.00),
(2, 7, '2024-03-10', '2024-03-20', 0.00),
(2, 9, curdate(), null, 0.00),      
(3, 8, curdate(), null, 0.00);

update books set available_copies = available_copies - 1 where book_id in (9, 8);

update books
set available_copies = available_copies + 1
where book_id = 7;

delete from members
where member_id not in (
    select distinct member_id
    from transactions
    where borrow_date >= date_sub(curdate(), interval 1 year)
);

select title, available_copies
from books
where available_copies > 0;

select title, published_date
from books
where published_date > '2015-12-31';

select title, price
from books
order by price desc
limit 5;

select name, membership_date
from members
where membership_date < '2022-01-01';

select title, category, price
from books
where category = 'science' and price < 500.00;

select title, available_copies
from books
where not available_copies > 0;

select m.name, m.membership_date, count(t.transaction_id) as total_borrows
from members m
left join transactions t on m.member_id = t.member_id
group by m.member_id, m.name, m.membership_date
having m.membership_date > '2020-12-31' or count(t.transaction_id) > 3;

select title
from books
order by title asc;

select m.name, count(t.transaction_id) as total_books_borrowed
from members m
join transactions t on m.member_id = t.member_id
group by m.name
order by total_books_borrowed desc;

select category, count(book_id) as total_books
from books
group by category
order by total_books desc;

select category, count(book_id) as total_books
from books
group by category;

select avg(price) as average_book_price
from books;

select b.title, count(t.transaction_id) as times_borrowed
from books b
join transactions t on b.book_id = t.book_id
group by b.title
order by times_borrowed desc
limit 1;

select sum(fine_amount) as total_fines_collected
from transactions;

select b.title, a.name as author_name
from books b
inner join authors a on b.author_id = a.author_id;

select m.name as member_name, b.title as book_title, t.borrow_date
from members m
left join transactions t on m.member_id = t.member_id
left join books b on t.book_id = b.book_id
where t.transaction_id is not null;

select b.title
from books b
left join transactions t on b.book_id = t.book_id
where t.transaction_id is null;

select m.name
from members m
left join transactions t on m.member_id = t.member_id
where t.transaction_id is null;

select distinct b.title
from books b
where b.book_id in (
    select t.book_id
    from transactions t
    where t.member_id in (
        select member_id
        from members
        where membership_date > '2022-12-31'
    )
);

select b.title
from books b
where b.book_id = (
    select book_id
    from transactions
    group by book_id
    order by count(transaction_id) desc
    limit 1
);

select name
from members
where member_id not in (
    select distinct member_id
    from transactions
);

select year(published_date) as publication_year, count(book_id) as total_books
from books
group by publication_year
order by publication_year desc;

select transaction_id, borrow_date, return_date, datediff(return_date, borrow_date) as days_borrowed
from transactions
where return_date is not null;

select transaction_id, date_format(borrow_date, '%d-%m-%Y') as formatted_borrow_date
from transactions;

select ucase(title) as uppercase_title
from books;

select trim(name) as trimmed_author_name
from authors;

select
    name,
    coalesce(email, 'not provided') as member_email
from members;

select
    m.name,
    case
        when exists (
            select 1
            from transactions t
            where t.member_id = m.member_id
            and t.borrow_date >= date_sub(curdate(), interval 6 month)
        ) then 'active'
        else 'inactive'
    end as membership_status
from members m;

select
    title,
    published_date,
    case
        when year(published_date) > 2020 then 'new arrival'
        when year(published_date) < 2000 then 'classic'
        else 'regular'
    end as book_category_label
from books
order by published_date desc;

with borrowcounts as (
    select book_id, count(transaction_id) as borrow_count
    from transactions
    group by book_id
)
select
    b.title,
    bc.borrow_count,
    rank() over (order by bc.borrow_count desc) as borrow_rank
from books b
join borrowcounts bc on b.book_id = bc.book_id
order by borrow_rank;

select
    m.name as member_name,
    t.borrow_date,
    b.title as book_title,
    count(t.transaction_id) over (
        partition by m.member_id
        order by t.borrow_date
    ) as cumulative_borrows
from members m
join transactions t on m.member_id = t.member_id
join books b on t.book_id = b.book_id
order by m.member_id, t.borrow_date;