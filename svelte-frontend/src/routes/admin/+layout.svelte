<script>
    import { onMount } from 'svelte';
    import { goto } from '$app/navigation';

    let loading = true;

    onMount(async () => {
        const res = await fetch('http://localhost:4567/api/user', {
            credentials: 'include'
        });

        const data = await res.json();

        if (!data.logged_in || data.role !== 'admin') {
            await goto('/login');
            return;
        }

        loading = false;
    });
</script>

<div>
    
    <!-- SIDEBAR -->
    <aside class="bg-black text-white p-4 flex justify-center flex-col">
        <h3 class="text-center font-bold">Admin</h3>

        <div class="m-2 flex flex-wrap justify-center">
            <a href="/admin/dashboard" class="outline rounded p-1 m-1">Dashboard</a>
            <a href="/admin/users" class="outline rounded p-1 m-1">Users</a>
            <a href="/admin/categories" class="outline rounded p-1 m-1">Categories</a>
            <a href="/admin/creators" class="outline rounded p-1 m-1">Creators</a>
            <a href="/admin/products" class="outline rounded p-1 m-1">Products</a>
            <a href="/admin/options" class="outline rounded p-1 m-1">Merch Values</a>
        </div>
    </aside>

    <!-- MAIN CONTENT -->
    <main class="bg-black">
        <slot />
    </main>

</div>