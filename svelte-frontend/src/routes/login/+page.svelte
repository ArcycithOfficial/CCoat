<script>
    import { goto } from '$app/navigation';
    let email = '';
    let password = '';
    let message = '';

    async function login() {
        console.log("LOGIN CLICKED"); 
        const res = await fetch('http://localhost:4567/api/login', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            credentials: 'include',
            body: JSON.stringify({ email, password })
        });
        console.log("STATUS", res.status)
        const text = res.text();
        console.log("RESPONSE", text);
        
        let data = await res.json();
        try {
            data = JSON.parse(text);
        } catch (e) {
            console.error("JSON NO RESPONSE");
            return
        }
        
        if (data.success) {
            goto('/');
        } else {
            message = data.message;
        }
    }
</script>

<form on:submit|preventDefault={login}>
    <label>Email <input bind:value={email} type="email"></label>
    <label>Password <input bind:value={password} type="password"></label>
    <button type="submit">Log in</button>
    <p>{message}</p>
</form>