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


<section class="text-white flex justify-center">
<div class="bg-purple-950 rounded p-4">
<h1 class="font-bold text-center">Admin - Users</h1>
<div class="flex flex-col gap-2">
{#each users as user}
    <div class="flex gap-2 justify-between">
        {user.username} ({user.role})
        <button on:click={() => deleteUser(user.id)} class="bg-red-600 px-2 rounded outline-1 outline-black text-sm">Delete</button>
    </div>
{/each}
</div>
</div>
</section>
