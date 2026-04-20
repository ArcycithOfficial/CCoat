<script>
    import { onMount } from 'svelte';
    import { apiFetch } from '$lib/api';

    let users = [];

    onMount(async () => {
        const res = await apiFetch('http://localhost:4567/admin/users');
        users = await res.json();
    });

    async function deleteUser(id) {
        const res = await apiFetch(`http://localhost:4567/admin/users/${id}`, {
            method: 'DELETE'
        });

        const data = await res.json();

        if (data.success) {
            users = users.filter(u => u.id !== id);
        }
    }
</script>

<h1>Admin - Users</h1>

{#each users as user}
    <div>
        {user.username} ({user.role})
        <button on:click={() => deleteUser(user.id)}>Delete</button>
    </div>
{/each}