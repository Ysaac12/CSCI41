CREATE TABLE customer (
	customerno INT NOT NULL PRIMARY KEY,
	lastname VARCHAR(255),
	firstname VARCHAR(255),
	address VARCHAR(255),
	city VARCHAR(255),
	state VARCHAR(255),
	zip VARCHAR(5),
	referredby INT,
	FOREIGN KEY (referredby) REFERENCES customer(customerno)
);

CREATE TABLE orders (
	orderno INT NOT NULL PRIMARY KEY,
	customerno INT,
	orderdate DATE,
	shipdate DATE,
	shipstreet VARCHAR(255),
	shipcity VARCHAR(255),
	shipstate VARCHAR(255),
	shipzip VARCHAR(255),
	FOREIGN KEY (customerno) REFERENCES customer(customerno)
);

CREATE TABLE author (
	authorID VARCHAR(4) NOT NULL PRIMARY KEY,
	lname VARCHAR(255),
	fname VARCHAR(255)
);

CREATE TABLE publisher (
	pubID INT NOT NULL PRIMARY KEY,
	name VARCHAR(255),
	contact VARCHAR(25),
	phone VARCHAR(25)
);

CREATE TABLE book (
	ISBN VARCHAR(10) NOT NULL PRIMARY KEY,
	title VARCHAR(30),
	pubdate DATE,
	pubID INT,
	cost FLOAT(2),
	retail FLOAT(2),
	category VARCHAR(12) ,
	FOREIGN KEY (pubID) REFERENCES publisher(pubID),
	CHECK
	 ( category IN ('Computer', 'Cooking', 'Family Life', 'Fitness', 'Children', 'Literature', 'Business', 'Self Help'))
);

CREATE TABLE bookauthor (
	ISBN VARCHAR(10) NOT NULL,
	authorid VARCHAR(4),
	PRIMARY KEY( ISBN, authorid ),
	FOREIGN KEY(isbn) REFERENCES book(isbn),
	FOREIGN KEY(authorid) REFERENCES author(authorid)
);

CREATE TABLE orderitem (
	orderno INT NOT NULL,
	itemno INT NOT NULL,
	ISBN VARCHAR(10),
	quantity INT,
	PRIMARY KEY(orderno, itemno), 
	FOREIGN KEY(orderno) REFERENCES orders(orderno),
	FOREIGN KEY(ISBN) REFERENCES book(ISBN)
);


-- 1
SELECT b.title, b.retail, p.name
FROM book b, publisher p
WHERE b.category IN ('Computer')
ORDER BY b.retail DESC
LIMIT 1;
-- 2
SELECT DISTINCT c.customerno, CONCAT(c.firstname, ' ', c.lastname) "Customer Name"
FROM customer c, customer r
WHERE c.customerno = r.referredby
ORDER BY c.customerno;
-- 3
SELECT DISTINCT b.ISBN, b.title AS "Book Title", p.name "Publisher", b.retail "Retail Price"
FROM book b, publisher p
WHERE b.pubID = p.pubID 
AND b.retail > (SELECT AVG(cost) FROM book);
-- 4
SELECT DISTINCT b.ISBN ISBN, b.title "Book Title",  b.retail "Retail Price"
FROM book b, customer c, orders o, orderitem oi
WHERE c.customerno = 1001
AND o.orderno = oi.orderno
AND c.customerno = o.customerno
AND oi.ISBN = b.ISBN;
-- 5
SELECT DISTINCT b.title, b.category, p.name, p.contact, p.phone
FROM book b, publisher p, bookauthor ba, author a
WHERE a.lname ILIKE '%kzochsky%'
AND a.fname ILIKE '%tamara%'
AND b.pubID = p.pubID
AND ba.ISBN = b.ISBN 
AND ba.authorID = a.authorID;
-- 6
SELECT DISTINCT b.ISBN, b.title, b.category 
FROM book b, publisher p
WHERE p.pubID = 5
AND b.pubID = p.pubID
AND b.retail > (SELECT AVG(cost)FROM book);
-- 7
SELECT DISTINCT b.ISBN, b.title, b.category,b.retail
FROM book b 
WHERE b.retail > (
    SELECT max(retail) 
    FROM book 
    WHERE book.category = 'Cooking'
)
ORDER BY b.ISBN ASC;
-- 8
SELECT DISTINCT b.ISBN, b.title, b.category, b.retail
FROM book b, orderitem oi, orders o
WHERE b.ISBN NOT IN (select ISBN FROM orderitem);

-- 9
SELECT DISTINCT o.orderno "Order Number", o.shipdate "Date of Shipping", CONCAT(c.firstname,' ', c.lastname) "Customer's Name"
FROM orders o, customer c
WHERE o.customerno = c.customerno
AND o.orderno <> 1017
AND o.shipstate IN (
    SELECT state
    FROM customer
    WHERE customer.firstname = 'STEVE'
    AND customer.lastname = 'SCHELL'
);
-- 10
SELECT DISTINCT CONCAT(c.firstname,' ', c.lastname) "Customer Name", c.state "State"
FROM customer c, orders o, book b, orderitem oi
WHERE b.retail = (SELECT MIN(retail) FROM book)
AND c.customerno = o.customerno
AND b.isbn = oi.ISBN
AND o.orderno = oi.orderno;

