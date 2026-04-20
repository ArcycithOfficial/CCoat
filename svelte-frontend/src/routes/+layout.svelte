

<script>
  	import Navbar from '$lib/side_components/Nav.svelte';
	import Footer from '$lib/components/Footer.svelte';
	import './layout.css';

	
	let csrfToken = '';

async function loadCsrf() {
    const res = await fetch('http://localhost:4567/api/csrf', {
        credentials: 'include'
    });

    const data = await res.json();
    csrfToken = data.csrf;
}

	let { children } = $props();

</script>
<Navbar />
{@render children()}
<Footer />

