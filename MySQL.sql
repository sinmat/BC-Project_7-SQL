-- Using database
USE sakila;

-- Displaying columns from "actor" table
SELECT first_name, last_name FROM actor;

-- Merging first and last name into one column "Actor Name"
SELECT CONCAT(first_name, ' ', last_name) AS 'Actor Name' FROM actor;

-- Query - certain columns meeting one condition (name is Joe)
SELECT actor_id, first_name, last_name FROM actor WHERE first_name = "Joe";

-- Query - meeting one condition (last name contain GEN)
SELECT * FROM actor WHERE last_name like "%GEN%";

-- Query - meeting one condition (last name contain LI), turning columns
SELECT last_name, first_name FROM actor WHERE last_name like "%LI%";

-- Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT country_id, country FROM country
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

-- Create a column in the table actor named description and use the data type BLOB.
ALTER TABLE actor
ADD COLUMN description BLOB;

-- Delete the description column
ALTER TABLE actor
DROP COLUMN description;

-- List the last names of actors, as well as how many actors have that last name
SELECT last_name, count(*)
FROM actor
GROUP BY last_name;

-- List last names and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT last_name, COUNT(*)
FROM actor
GROUP BY last_name
HAVING COUNT(*) > 2;

-- HARPO WILLIAMS was entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
UPDATE actor
SET first_name = "HARPO"
WHERE first_name = "GROUCHO" AND last_name = "WILLIAMS";

-- In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
UPDATE actor
SET first_name = "GROUCHO"
WHERE first_name = "HARPO" AND last_name = "WILLIAMS";

--  You cannot locate the schema of the address table. Which query would you use to re-create it?
CREATE TABLE address_new_query(
id INT(10) NOT NULL AUTO_INCREMENT,
street_and_house_number VARCHAR(250),
city VARCHAR(50),
state VARCHAR(50),
country VARCHAR(50),
PRIMARY KEY(id)
);

-- Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
SELECT staff_id, first_name, last_name, address
FROM staff
LEFT JOIN address ON staff.address_id = address.address_id;

-- *** Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
SELECT first_name, last_name, SUM(amount) FROM staff 
LEFT JOIN payment ON staff.staff_id = payment.staff_id
WHERE YEAR(payment.payment_date) = 2005 AND DAYOFMONTH(payment.payment_date) = 8
GROUP BY staff.staff_id;

-- List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
SELECT title, COUNT(actor_id)
FROM film
LEFT JOIN film_actor ON film.film_id = film_actor.film_id
GROUP BY title;

-- How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT title, COUNT(inventory.film_id)
FROM film
LEFT JOIN inventory ON film.film_id = inventory.film_id
GROUP BY title
HAVING title = "Hunchback Impossible";

-- Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
SELECT first_name, last_name, SUM(amount)
FROM customer
LEFT JOIN payment ON customer.customer_id = payment.customer_id
GROUP BY customer.customer_id ORDER BY last_name;

-- Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
SELECT title
FROM film
WHERE language_id
IN (
	SELECT language_id
	FROM language
	WHERE name = "English" 
	)
AND title LIKE 'K%' OR title LIKE 'Q%';

-- Use subqueries to display all actors who appear in the film Alone Trip.
SELECT first_name, last_name
FROM actor
WHERE actor_id  
IN (
	SELECT actor_id
	FROM film_actor
	WHERE film_id
	IN (
		SELECT film_id
		FROM film
		WHERE title = "Alone Trip")
);

-- The names and email addresses of all Canadian customers. Use joins to retrieve this information.
SELECT first_name, last_name, email
FROM customer
WHERE address_id
IN(
	SELECT address_id
	FROM address
	WHERE city_id
	IN(
		SELECT city_id
		FROM city
		WHERE country_id
		IN(
			SELECT country_id
			FROM country
			WHERE country = "Canada")
	)
);

-- Identify all movies categorized as family films.
SELECT title
FROM film
WHERE film_id
IN(
	SELECT film_id
    FROM film_category
    WHERE category_id
    IN(
		SELECT category_id
        FROM category
        WHERE name = "Family")
	);

-- Display the most frequently rented movies in descending order.
SELECT film.film_id, film.title, COUNT(film.film_id) AS c FROM rental 
LEFT JOIN inventory ON rental.inventory_id = inventory.inventory_id
LEFT JOIN film ON inventory.film_id = film.film_id
GROUP BY film.film_id ORDER BY c DESC;

-- Write a query to display how much business, in dollars, each store brought in.
SELECT store.store_id, SUM(amount) FROM customer 
LEFT JOIN store ON customer.store_id = store.store_id
RIGHT JOIN payment ON customer.customer_id = payment.customer_id
GROUP BY store.store_id;

-- Write a query to display for each store its store ID, city, and country.
SELECT store.store_id, city.city, country.country
FROM store
LEFT JOIN address ON store.address_id = address.address_id
RIGHT JOIN city ON address.city_id = city.city_id
RIGHT JOIN country ON city.country_id = country.country_id;

-- List the top five genres in gross revenue in descending order. 
SELECT category.name, SUM(amount) AS a
FROM category
LEFT JOIN film_category ON category.category_id = film_category.category_id
RIGHT JOIN inventory ON film_category.film_id = inventory.film_id
RIGHT JOIN rental ON inventory.inventory_id = rental.inventory_id
RIGHT JOIN payment ON rental.rental_id = payment.rental_id
GROUP BY category.name ORDER BY a DESC;

-- Top five genres by gross revenue. Use the solution from the problem above to create a view.
CREATE VIEW top_five_genres AS
	SELECT category.name, SUM(amount) AS a
	FROM category
	LEFT JOIN film_category ON category.category_id = film_category.category_id
	RIGHT JOIN inventory ON film_category.film_id = inventory.film_id
	RIGHT JOIN rental ON inventory.inventory_id = rental.inventory_id
	RIGHT JOIN payment ON rental.rental_id = payment.rental_id
	GROUP BY category.name ORDER BY a DESC;

-- Display the view
SELECT * FROM top_five_genres;

-- Dropping a view:
DROP VIEW top_five_genres;
