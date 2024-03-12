# 🔖 Bookify OBMS
> 🐳 Online Bookstore Management System (OBMS)

## 📝 [`TO-DO`](https://mastekgroup.sharepoint.com/:x:/r/sites/DSAR/_layouts/15/Doc.aspx?sourcedoc=%7B2848B15B-01BB-4355-A183-606D3EB11455%7D&file=Participantlist.xlsx&action=default&mobileredirect=true)

![image](https://github.com/Ayon-SSP/Ayon-SSP/assets/80549753/8c5630bf-8343-48ca-aba4-e9b7d6759666)


<table border="1">
  <caption>Online Bookstore Management System</caption>
  <thead>
    <tr>
      <th>Process</th>
      <th>Step</th>
      <th>Description</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td rowspan="2">Book Catalog Management</td>
      <td>1</td>
      <td>Admin adds new books to the catalog, specifying details such as title, author, genre, price, etc.</td>
    </tr>
    <tr>
      <td>2</td>
      <td>System updates the book inventory and displays new additions on the website.</td>
    </tr>
    <tr>
      <td rowspan="3">Order Processing</td>
      <td>1</td>
      <td>Customers browse the bookstore website and add books to their shopping cart.</td>
    </tr>
    <tr>
      <td>2</td>
      <td>Upon checkout, system calculates the total cost, applies discounts (if any), and generates an order confirmation.</td>
    </tr>
    <tr>
      <td>3</td>
      <td>Admin processes orders, updates inventory, and notifies customers about order status (shipping details, delivery estimates, etc.).</td>
    </tr>
  </tbody>
</table>


## 🌲Project Structure
```css
online-bookstore-ms/

|__ README.md
|__ LICENSE
|__ .gitignore

|__ docs/
  |__ requirements.md
  |__ architecture.md
  |__ system-design.md
  |__ database-schema.sql
  |__ er-diagram.png
  |__ class-diagram.uml
  |__ sequence-diagram.uml
  |__ other-diagrams.uml (optional)

|__ src/
  |__ main/
    |__ java/
      |__ com/
        |__ bookify/
          |__ model/           // POJO classes (JavaBeans)
          |__ dao/             // Data Access Objects (DAO)
          |__ service/         // Business logic layer
          |__ controller/      // Servlets for request handling
          |__ util/            // Utility classes
    |__ webapp/
      |__ WEB-INF/
        |__ lib/              // JAR files for JDBC drivers and other dependencies
        |__ classes/          // Compiled Java classes
        |__ web.xml           // Deployment descriptor
      |__ resources/          // Configuration files (e.g., database.properties)
      |__ css/                // CSS files for styling
      |__ js/                 // JavaScript files
      |__ images/             // Image files
      |__ WEB-INF/
        |__ jsp/              // JSP files for the front end

|__ db/
  |__ init.sql
  |__ test-data.sql (optional)

|__ tests/
  |__ backend/
    |__ unit/
    |__ integration/
  |__ frontend/
    |__ unit/
    |__ integration/
```
