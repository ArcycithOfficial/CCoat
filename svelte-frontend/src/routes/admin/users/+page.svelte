<script>
    import { onMount } from 'svelte';

    let users = [];

    onMount(async () => {
        const res = await fetch('http://localhost:4567/admin/users', {
            credentials: 'include'
        });

        users = await res.json();
    });

    async function deleteUser(id) {
        await fetch(`http://localhost:4567/admin/users/${id}`, {
            method: 'DELETE',
            credentials: 'include'
        });

        users = users.filter(u => u.id !== id);
    }
</script>

<h1>Admin - Users</h1>

{#each users as user}
    <div>
        {user.username} ({user.role})
        <button on:click={() => deleteUser(user.id)}>Delete</button>
    </div>
{/each}