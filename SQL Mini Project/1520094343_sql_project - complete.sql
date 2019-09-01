/* Welcome to the SQL mini project. For this project, you will use
Springboard' online SQL platform, which you can log into through the
following link:

https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

Note that, if you need to, you can also download these tables locally.

In the mini project, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */



/* Q1: Some of the facilities charge a fee to members, but some do not.
Please list the names of the facilities that do. */

/* By selecting where membercost is greater than 0, we get the correct
asnwer.*/

SELECT name, membercost
FROM  `Facilities` 
WHERE membercost > 0
ORDER BY membercost


/* Q2: How many facilities do not charge a fee to members? */     

/* Use count for a new column, free_for_members, and where 
membercost is 0 to determine the total. */

SELECT COUNT( membercost ) AS free_for_members
FROM  `Facilities` 
WHERE membercost = 0


/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

/* Selecting the requested columns and by finding where the membercost 
is not free but still less than 20% of the monthly maintainance.*/

SELECT facid, name, membercost, monthlymaintenance
FROM  `Facilities` 
WHERE membercost > 0 AND (membercost / monthlymaintenance) < 0.20
ORDER BY membercost


/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */

/* IN can be used instead of OR to get specifically the values where 
facid is 1 or 5. */

SELECT * 
FROM  `Facilities` 
WHERE facid
IN ( 1, 5 ) 


/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */

/* Using CASE, if the monthly maintenance is less than 100, it is classified
as 'cheap', otherwise it is 'expensive'. */

SELECT name, monthlymaintenance, 
       CASE WHEN monthlymaintenance <=100 THEN  'cheap'
       ELSE  'expensive' END AS cost_classification
FROM  `Facilities` 
WHERE 1 
ORDER BY monthlymaintenance


/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */

/* In WHERE, if we specifiy that joindate should just select for the latest
date, we can get the name of the newest member(s). */

SELECT firstname, surname, joindate
FROM  `Members` 
WHERE joindate = (SELECT MAX( joindate ) 
      FROM Members )


/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

/* Begin by using CONCAT to put together the first and last names of mebers as well
DSITINCT to ensure no duplicates. To make sure we can connect the tables correctly, 
we connect Bookings and Members with memid and Bookings and Facilities with facid.
Finally, only select facilities that contain 'Tennis Court' and order by ascending order. */

SELECT DISTINCT CONCAT( surname, ', ', firstname ) AS member_name, 
       Facilities.name AS court_name
FROM Members
    INNER JOIN Bookings ON Members.memid = Bookings.memid
    INNER JOIN Facilities ON Bookings.facid = Facilities.facid
WHERE Facilities.name LIKE  'Tennis court%'
ORDER BY member_name ASC 



/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */


/*Similar to the last problem, CONCAT the member and guest names. To determine the total 
for that day, the guest costs are multiplied by the slots values and member costs 
are multiplied by the slots values separately. As above, the tables are joined on facid 
memid. Using WHERE, we connect the specific date and to the cost case. Finally, it is ordered. */

SELECT Facilities.name AS facility_name, CONCAT( surname, ', ', firstname ) AS member_name,
       CASE WHEN Bookings.memid = 0 THEN Facilities.guestcost * Bookings.slots
       ELSE Facilities.membercost * Bookings.slots END AS total_cost
FROM Bookings
     INNER JOIN Members ON Bookings.memid = Members.memid
     INNER JOIN Facilities ON Bookings.facid = Facilities.facid
WHERE DATE_FORMAT(starttime, '%Y-%m-%d') = '2012-09-14'
      AND (CASE WHEN Bookings.memid = 0 THEN Facilities.guestcost * Bookings.slots
      ELSE Facilities.membercost * Bookings.slots END) > 30
ORDER BY total_cost DESC


/* Q9: This time, produce the same result as in Q8, but using a subquery. */


/* Similar to above, except we use a subquery to label and select the necessary 
columns form all tables. */

SELECT facility, CONCAT( surname, ', ', firstname ) AS member_name,
       CASE WHEN id = 0 THEN guestcost * slots
       ELSE membercost * slots END AS total_cost
FROM (SELECT Facilities.name AS facility,
             Members.surname AS surname, 
             Members.firstname AS firstname, 
             Members.memid AS id,
             Facilities.guestcost AS guestcost,
             Facilities.membercost AS membercost,
             Bookings.slots AS slots
      FROM Bookings
           INNER JOIN Members ON Bookings.memid = Members.memid
           INNER JOIN Facilities ON Bookings.facid = Facilities.facid
      WHERE DATE_FORMAT(starttime, '%Y-%m-%d') = '2012-09-14') sub
WHERE (CASE WHEN id = 0 THEN guestcost * slots
      ELSE membercost * slots END) > 30  
ORDER BY total_cost DESC      
      

/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

/* Selecting the necessary columns through a subquery, we also sum the total 
revenue, distinguishing between guest and member fees. The tables are joined 
through the facid and memid columns. With HAVING, only facilities with revenue
less than 1000 are selected. */

SELECT facility, SUM(CASE WHEN id = 0 THEN guestcost * slots
       ELSE membercost * slots END) AS total_revenue
FROM (SELECT Facilities.name AS facility, 
             Members.memid AS id, 
             Facilities.guestcost AS guestcost, 
             Facilities.membercost AS membercost, 
             Bookings.slots AS slots
      FROM Bookings
           INNER JOIN Members ON Bookings.memid = Members.memid
           INNER JOIN Facilities ON Bookings.facid = Facilities.facid) sub
GROUP BY facility
HAVING total_revenue < 1000
ORDER BY total_revenue DESC


