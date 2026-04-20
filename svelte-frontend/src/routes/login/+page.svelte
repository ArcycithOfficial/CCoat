<script>
    import { goto } from '$app/navigation';
    import { csrf } from '$lib/stores';
    let csrfToken = '';
    let email = '';
    let password = '';
    let message = '';

    async function getCsrf() {
            const res = await fetch('http://localhost:4567/api/csrf', {
                credentials: 'include'
            });

            const data = await res.json();
            return data.csrf;
    }

    async function login() {
        console.log("LOGIN CLICKED"); 
        const res = await fetch('http://localhost:4567/api/login', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            credentials: 'include',
            body: JSON.stringify({ email, password })
        });
        console.log("STATUS", res.status)
        
        const data = await res.json();

        if (data.success) {
            const token = await getCsrf();
            csrf.set(token);

            if (data.role === 'admin'){
                goto('/admin');
            }else{
            goto('/');
            }
        } else {
            message = data.message
        }
    }
</script>
<section>
<form on:submit|preventDefault={login}>
    <div>
    <label>Email <input bind:value={email} type="email"></label>
    <label>Password <input bind:value={password} type="password"></label>
    </div>
    <div>
    <button type="submit">Log in</button>
    </div>
    <p>{message}</p>
</form>
</section>

<style>
    section{

        padding: 50px;
        margin: 10px;
        background-color: lightblue;
    }
    button{
        border: black 2px solid;
        border-radius: 2px;

    }
</style>
