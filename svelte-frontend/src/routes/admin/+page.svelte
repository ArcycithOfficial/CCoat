<script>
    import { goto } from '$app/navigation';
</script>

<div style="display:flex; min-height:100vh;">
    
    <!-- SIDEBAR -->
    <aside style="width:200px; padding:20px; background:#111; color:white;">
        <h3>Admin</h3>

        <nav>
            <p on:click={() => goto('/admin')} style="cursor:pointer;">Dashboard</p>
            <p on:click={() => goto('/admin/users')} style="cursor:pointer;">Users</p>
            <p on:click={() => goto('/admin/categories')} style="cursor:pointer;">Categories</p>
        </nav>
    </aside>

    <!-- MAIN CONTENT -->
    <main style="flex:1; padding:20px;">
        <slot />
    </main>

</div>