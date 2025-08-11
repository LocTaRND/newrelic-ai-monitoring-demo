import React, { useState, useEffect } from 'react';
import UserService from '../services/userService';

const UserList = () => {
  const [users, setUsers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [showAddForm, setShowAddForm] = useState(false);
  const [newUser, setNewUser] = useState({ name: '', email: '' });

  useEffect(() => {
    fetchUsers();
  }, []);

  const fetchUsers = async () => {
    try {
      setLoading(true);
      const userData = await UserService.getAllUsers();
      setUsers(userData);
      setError(null);
    } catch (err) {
      setError('Failed to fetch users');
      console.error('Error:', err);
    } finally {
      setLoading(false);
    }
  };

  const handleDeleteUser = async (userId) => {
    if (window.confirm('Are you sure you want to delete this user?')) {
      try {
        await UserService.deleteUser(userId);
        await fetchUsers(); // Refresh the list
      } catch (err) {
        setError('Failed to delete user');
        console.error('Error:', err);
      }
    }
  };

  const handleAddUser = async (e) => {
    e.preventDefault();
    if (!newUser.name || !newUser.email) {
      setError('Name and email are required');
      return;
    }
    
    try {
      await UserService.createUser(newUser);
      setNewUser({ name: '', email: '' });
      setShowAddForm(false);
      await fetchUsers(); // Refresh the list
      setError(null);
    } catch (err) {
      setError('Failed to create user');
      console.error('Error:', err);
    }
  };

  if (loading) return <div>Loading users...</div>;
  if (error) return <div style={{color: 'red'}}>Error: {error}</div>;

  return (
    <div>
      <h2>User Management</h2>
      <div style={{marginBottom: '20px'}}>
        <button onClick={fetchUsers} style={{marginRight: '10px'}}>
          Refresh Users
        </button>
        <button 
          onClick={() => setShowAddForm(!showAddForm)}
          style={{backgroundColor: '#007bff', color: 'white', border: 'none', padding: '8px 16px', cursor: 'pointer'}}
        >
          {showAddForm ? 'Cancel' : 'Add User'}
        </button>
      </div>

      {showAddForm && (
        <form onSubmit={handleAddUser} style={{marginBottom: '20px', padding: '15px', border: '1px solid #ddd', borderRadius: '5px'}}>
          <h3>Add New User</h3>
          <div style={{marginBottom: '10px'}}>
            <input
              type="text"
              placeholder="Name"
              value={newUser.name}
              onChange={(e) => setNewUser({...newUser, name: e.target.value})}
              style={{padding: '8px', marginRight: '10px', width: '200px'}}
            />
            <input
              type="email"
              placeholder="Email"
              value={newUser.email}
              onChange={(e) => setNewUser({...newUser, email: e.target.value})}
              style={{padding: '8px', marginRight: '10px', width: '200px'}}
            />
            <button 
              type="submit"
              style={{backgroundColor: '#28a745', color: 'white', border: 'none', padding: '8px 16px', cursor: 'pointer'}}
            >
              Create User
            </button>
          </div>
        </form>
      )}
      
      {users.length === 0 ? (
        <p>No users found.</p>
      ) : (
        <table style={{width: '100%', borderCollapse: 'collapse'}}>
          <thead>
            <tr style={{backgroundColor: '#f5f5f5'}}>
              <th style={{border: '1px solid #ddd', padding: '8px'}}>ID</th>
              <th style={{border: '1px solid #ddd', padding: '8px'}}>Name</th>
              <th style={{border: '1px solid #ddd', padding: '8px'}}>Email</th>
              <th style={{border: '1px solid #ddd', padding: '8px'}}>Actions</th>
            </tr>
          </thead>
          <tbody>
            {users.map(user => (
              <tr key={user.id}>
                <td style={{border: '1px solid #ddd', padding: '8px'}}>{user.id}</td>
                <td style={{border: '1px solid #ddd', padding: '8px'}}>{user.name}</td>
                <td style={{border: '1px solid #ddd', padding: '8px'}}>{user.email}</td>
                <td style={{border: '1px solid #ddd', padding: '8px'}}>
                  <button 
                    onClick={() => handleDeleteUser(user.id)}
                    style={{backgroundColor: '#dc3545', color: 'white', border: 'none', padding: '5px 10px', cursor: 'pointer'}}
                  >
                    Delete
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      )}
    </div>
  );
};

export default UserList;
