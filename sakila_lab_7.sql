----------------
-- LAB 7 SQL --
---------------- 

use sakila;

-- 1. How many copies of the film _Hunchback Impossible_ exist in the inventory system?

select count(inventory_id) as number_copies
from inventory
where film_id = (
	select film_id
	from film	
	where title = "Hunchback Impossible"
);

-- 2. List all films whose length is longer than the average of all the films.

select title, length
from film
where length > (
	select avg(length) 
	from film
);

-- 3. Use subqueries to display all actors who appear in the film _Alone Trip_.

-- buscamos el film id de la pelicula "alone_trip"
select film_id
from film
where title = "Alone Trip";

-- buscamos los id de los actores que participan en la pelicula "alone_trip"
select actor_id
from film_actor
where film_id = (
	select film_id
	from film
	where title = "Alone Trip"
);

-- filamente buscamos el nombre y apellido de los actores a través de su id.
select first_name, last_name
from actor
where actor_id IN (
	select actor_id
	from film_actor
	where film_id = (
		select film_id
		from film
		where title = "Alone Trip"
	)
);


/*4. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
Identify all movies categorized as family films.*/


select category_id
from category
where name = "Family";


select film_id
from film_category
where category_id =(
	select category_id
	from category
	where name = "Family"
    );

select title
from film
where film_id in (
	select film_id
	from film_category
	where category_id =(
		select category_id
		from category
		where name = "Family"
    )
);

/*5. Get name and email from customers from Canada using subqueries. Do the same with joins. Note that to create a join, 
you will have to identify the correct tables with their primary keys and foreign keys, that will help you get the relevant information.*/

select country_id
from country
where country = "Canada";

select city_id
from city
where country_id = (
	select country_id
	from country
	where country = "Canada"
    );

select address_id
from address
where city_id in (
	select city_id
	from city
	where country_id = (
		select country_id
		from country
		where country = "Canada"
		)
	);

select first_name, last_name, email
from customer
where address_id in (
	select address_id
	from address
	where city_id in (
		select city_id
		from city
		where country_id = (
			select country_id
			from country
			where country = "Canada"
		)
	)
);


/*6. Which are films starred by the most prolific actor? Most prolific actor is defined as the actor that has acted in the most number of films. 
First you will have to find the most prolific actor and then use that actor_id to find the different films that he/she starred.*/

-- Primero vamos a bucar el actor más prolífico:
select actor_id, count(film_id) as num_films
from film_actor
group by actor_id
order by num_films desc
limit 1;

-- Segundo, vamos a buscar que actor es el más prolifico
select actor_id
from (
select actor_id, count(film_id) as num_films
from film_actor
group by actor_id
order by num_films desc
limit 1) as prolifict_actor;

-- Vamos a ver el id de las peliculas en las que ha participado.
select film_id
from film_actor
where actor_id = (
	select actor_id
	from (
	select actor_id, count(film_id) as num_films
		from film_actor
		group by actor_id
		order by num_films desc
		limit 1) as prolifict_actor
	);

-- Por último vamos a ver en que pelicias ha trabajado.
select title
from film
where film_id in (
	select film_id
	from film_actor
	where actor_id = (
		select actor_id
		from (
		select actor_id, count(film_id) as num_films
			from film_actor
			group by actor_id
			order by num_films desc
			limit 1) as prolifict_actor
	)
);


/*7. Films rented by most profitable customer. You can use the customer table and payment table 
to find the most profitable customer ie the customer that has made the largest sum of payments*/

 -- Buscamos el costumer_id del cliente más rentable.
 
select customer_id
from payment
group by customer_id
order by sum(amount) desc
limit 1;

-- Segundo vamos a averigurar que ha alquilado.

select inventory_id
from rental
where customer_id = (
	select customer_id
	from payment
	group by customer_id
	order by sum(amount) desc
	limit 1
    );

-- Estamos buscando los film_id.

select film_id
from inventory
where inventory_id in (
	select inventory_id
	from rental
	where customer_id = (
		select customer_id
		from payment
		group by customer_id
		order by sum(amount) desc
		limit 1
		)
);

-- Por últim los títulos de las películas que este cliente ha alquilado.

select title
from film
where film_id in (
	select film_id
	from inventory
	where inventory_id in (
		select inventory_id
		from rental
		where customer_id = (
			select customer_id
			from payment
			group by customer_id
			order by sum(amount) desc
			limit 1
			)
	)
)
order by title; 

/*8. Get the `client_id` and the `total_amount_spent` of those clients 
who spent more than the average of the `total_amount` spent by each client.*/

-- He supuesto que client_id era customer_id

-- Vamos a calcular la cantidad gastada por cada cliente.
select customer_id, sum(amount) as total_amount_spent
from payment
group by customer_id;

-- Vamos a calcular la media 
select avg(total_amount_spent) 
from (
	select customer_id, sum(amount) as total_amount_spent
	from payment
	group by customer_id) as avg_spending;

-- Vamos a ver los clientes que gastan más que la media.

select customer_id, sum(amount) as total_amount_spent
from payment
group by customer_id
having sum(amount) > (
	select avg(total_amount_spent) from (
	select customer_id, sum(amount) as total_amount_spent
	from payment
	group by customer_id) as spending_by_customer
    )
    ;