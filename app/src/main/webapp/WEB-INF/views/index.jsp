<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<html>
<head>
    <title>User List</title>
    <style>
        body {
            font-family: Arial, sans-serif; /* Change font */
            background-color: #f4f4f9; /* Light background color */
            color: #333; /* Dark text color */
            margin: 0;
            padding: 20px; /* Add some padding around the page */
        }
        h2 {
            text-align: center; /* Center align the header */
            color: #4a76a8; /* Header color */
        }
        form {
            margin-bottom: 20px; /* Space between form and table */
            text-align: center; /* Center the form */
        }
        input[type="text"], input[type="email"] {
            padding: 10px; /* Padding inside input fields */
            margin: 5px; /* Margin between input fields */
            border: 1px solid #ccc; /* Light border around input */
            border-radius: 5px; /* Rounded corners */
        }
        input[type="submit"] {
            background-color: #4a76a8; /* Button color */
            color: white; /* Button text color */
            padding: 10px 20px; /* Button padding */
            border: none; /* No border */
            border-radius: 5px; /* Rounded corners */
            cursor: pointer; /* Pointer cursor on hover */
        }
        input[type="submit"]:hover {
            background-color: #3a5f8e; /* Darker shade on hover */
        }
        table {
            width: 100%; /* Full width */
            border-collapse: collapse; /* Remove spacing between cells */
            margin-top: 20px; /* Space above the table */
        }
        th, td {
            padding: 10px; /* Cell padding */
            text-align: left; /* Align text to the left */
            border: 1px solid #ddd; /* Light border */
        }
        th {
            background-color: #4a76a8; /* Header background color */
            color: white; /* Header text color */
        }
        tr:nth-child(even) {
            background-color: #f2f2f2; /* Light background for even rows */
        }
        tr:hover {
            background-color: #e8e8e8; /* Highlight row on hover */
        }
    </style>
</head>
<body>

<h2>User List</h2>
<form method="post" action="users">
    Name: <input type="text" name="name" required>
    Email: <input type="email" name="email" required>
    <input type="submit" value="Add User">
</form>
<table>
    <tr>
        <th>ID</th>
        <th>Name</th>
        <th>Email</th>
    </tr>
    <c:forEach var="user" items="${users}">
        <tr>
            <td>${user.id}</td>
            <td>${user.name}</td>
            <td>${user.email}</td>
        </tr>
    </c:forEach>
</table>

</body>
</html>
