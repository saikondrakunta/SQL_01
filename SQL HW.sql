
## Instructions

--1a. Display the first and last names of all actors from the table `actor`.

SELECT first_name, last_name 
FROM sakila.actor;

--1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`.

use sakila;
select *, concat(first_name, ' ', last_name) 
AS 'Actor Name' 
FROM actor;  

--2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?

USE sakila;
select actor_id, first_name, last_name 
from actor 
where first_name='JOE'; 

--2b. Find all actors whose last name contain the letters `GEN`:

SELECT * 
FROM actor 
WHERE last_name 
LIKE '%GEN%';

--2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order:

SELECT first_name, last_name
FROM actor WHERE last_name 
LIKE '%LI%' 
group by last_name, first_name;

--2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:

SELECT country_id, country 
FROM sakila.country 
WHERE country 
IN ('Afghanistan', 'Bangladesh','China');

--3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table `actor` named `description` and use the data type `BLOB` (Make sure to research the type `BLOB`, as the difference between it and `VARCHAR` are significant).

ALTER TABLE actor 
ADD Description BLOB AFTER last_name;

--3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the `description` column.

ALTER TABLE actor 
DROP COLUMN Description; 

--4a. List the last names of actors, as well as how many actors have that last name.

SELECT last_name, 
COUNT(*) 
FROM sakila.actor 
group by last_name;

--4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors

SELECT last_name, 
COUNT(*) 
FROM sakila.actor 
group by last_name 
HAVING count(*) >=2;

--4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`. Write a query to fix the record.

UPDATE actor 
SET first_name = 'GROUCHO' 
WHERE first_name = 'HARPO' 
	AND last_name = 'WILLIAMS';

--4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.

UPDATE actor 
SET first_name = 'HARPO' 
WHERE first_name = 'GROUCHO';

--5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?

 -- * Hint: [https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html](https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html)

CREATE TABLE address_2 (
address_id INT AUTO_INCREMENT NOT NULL PRIMARY KEY,
adress VARCHAR(100),
district VARCHAR(15),
city_id INT,
postal_code INT,
phone INT,
location BLOB);

--6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`:

SELECT first_name, last_name, address FROM sakila.address JOIN sakila.staff on staff.address_id = address.address_id;

--6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`.

USE sakila;
SELECT payment.staff_id,amount, 
SUM(payment.amount) as Total_Amount
FROM payment 
JOIN staff on staff.staff_id= payment.staff_id WHERE payment.payment_date LIKE '%2005-08%'
GROUP BY staff.first_name, staff.last_name; 

--6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.

SELECT title, actor_id, 
COUNT(*) 
FROM sakila.film 
INNER JOIN film_actor 
ON film.film_id = film_actor.film_id 
GROUP BY title;

--6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?

SELECT COUNT(*)
 FROM inventory
 WHERE film_id IN(
     SELECT film_id
     FROM film
     WHERE title = 'Hunchback Impossible'
    );
    
--6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. List the customers alphabetically by last name:

 -- ![Total amount paid](Images/total_payment.png)
  
SELECT customer.last_name, customer.first_name,
SUM(payment.amount) as Total_Amount
FROM sakila.payment 
INNER JOIN sakila.customer 
ON customer.customer_id = payment.payment_id 
GROUP BY last_name;

--7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity. Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.

SELECT title
FROM film 
WHERE title LIKE 'K%' 
OR title LIKE 'Q%'
AND language_id IN 
(SELECT language_id 
FROM language 
WHERE name='English');

--7b. Use subqueries to display all actors who appear in the film `Alone Trip`.

SELECT first_name, last_name 
FROM actor 
WHERE actor_id IN
(SELECT actor_id
    FROM film_actor
    WHERE film_id IN
    (
     SELECT film_id
     FROM film
     WHERE title = 'Alone Trip'
    ));
    
--7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.

SELECT first_name, last_name, email 
FROM sakila.customer
INNER JOIN address
	ON customer.address_id=address.address_id
INNER JOIN city
	ON address.city_id = city.city_id
INNER JOIN country
	ON city.country_id = country.country_id
WHERE country IN ('Canada');

--7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as _family_ films.

SELECT title 
FROM film
WHERE film_id IN(
SELECT film_id
FROM film_category
WHERE category_id IN(
SELECT category_id 
FROM category 
WHERE name = 'Family')
);

--7e. Display the most frequently rented movies in descending order.

SELECT film.title, 
COUNT(title) as Number_Rented
FROM sakila.film
INNER JOIN inventory 
	ON film.film_id = inventory.film_id
INNER JOIN rental
	ON inventory.inventory_id = rental.inventory_id
GROUP BY film.title
ORDER BY COUNT(*) DESC;

--7f. Write a query to display how much business, in dollars, each store brought in.

SELECT store.store_id, 
SUM(payment.amount) as Total_Amount
FROM sakila.payment
INNER JOIN rental 
	ON payment.rental_id = rental.rental_id
INNER JOIN inventory 
	ON rental.inventory_id = inventory.inventory_id
INNER JOIN store 
	ON inventory.store_id = store.store_id
GROUP BY store.store_id;

--7g. Write a query to display for each store its store ID, city, and country.

SELECT  store_id, city.city, country.country 
FROM sakila.store
JOIN address 
	ON store.address_id = address.address_id
JOIN city
	ON address.city_id = city.city_id
JOIN country 
	ON city.country_id = country.country_id;

--7h. List the top five genres in gross revenue in descending order. 
(**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)

Use sakila;
SELECT category.name, 
SUM(payment.amount) as Gross_Rev
FROM payment
JOIN rental
	ON payment.rental_id = rental.rental_id
JOIN inventory 
	ON rental.inventory_id = inventory.inventory_id
JOIN film_category
	ON inventory.film_id = film_category.film_id 
JOIN category
	ON film_category.category_id = category.category_id
GROUP BY category.name;

--8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.

CREATE VIEW Top_Five_Genre_by_Gross_Rev AS
SELECT category.name, 
SUM(payment.amount) as Gross_Rev
FROM payment
JOIN rental
	ON payment.rental_id = rental.rental_id
JOIN inventory 
	ON rental.inventory_id = inventory.inventory_id
JOIN film_category
	ON inventory.film_id = film_category.film_id 
JOIN category
	ON film_category.category_id = category.category_id
GROUP BY category.name;

--8b. How would you display the view that you created in 8a?

SELECT * FROM Top_Five_Genre_by_Gross_Rev;

--8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.

DROP VIEW Top_Five_Genre_by_Gross_Rev;


## Uploading Homework

* To submit this homework using BootCampSpot:

  * Create a GitHub repository.
  * Upload your .sql file with the completed queries.
  * Submit a link to your GitHub repo through BootCampSpot.
