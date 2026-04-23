<!-- src/routes/signup/+page.svelte -->
<script>
    import { goto } from '$app/navigation';

    let username = '';
    let email = '';
    let password = '';
    let error = '';

    async function signup() {
        const res = await fetch('http://localhost:4567/api/signup', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            credentials: 'include',
            body: JSON.stringify({ username, email, password })
        });

        await goto('/login');
    }
</script>

<div>
    <h1>Sign up</h1>

    {#if error}
        <p style="color:red">{error}</p>
    {/if}

    <input type="text" placeholder="Username" bind:value={username} />
    <input type="email" placeholder="Email" bind:value={email} />
    <input type="password" placeholder="Password" bind:value={password} />
    <button on:click={signup}>Sign up</button>

    <p>Already have an account? <a href="/login">Login</a></p>
</div>