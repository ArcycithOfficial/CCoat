<script>
    import { goto } from '$app/navigation';
    let email = '';
    let password = '';
    let message = '';

    async function login() {
        const res = await fetch('http://localhost:4567/api/login', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ email, password })
        });
        const data = await res.json();
        if (data.success) {
            goto('/');
        } else {
            message = data.message;
        }
    }
</script>

<form action="/login">
    <label>Email <input bind:value={email} type="email"></label>
    <label>Password <input bind:value={password} type="password"></label>
    <button type="submit">Log in</button>
    <p>{message}</p>
</form>