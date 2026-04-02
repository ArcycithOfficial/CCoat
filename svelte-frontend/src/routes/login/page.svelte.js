import { redirect, fail } from '@sveltejs/kit';

export const actions = {
  default: async ({ request, fetch, cookies }) => {
    const formData = await request.formData();
    const email = formData.get('email');
    const password = formData.get('password');

    let data;

    try {
      const res = await fetch('http://localhost:4567/api/login', {
        method: 'POST',
        body: JSON.stringify({ email, password }),
        headers: { 'Content-Type': 'application/json' }
      });

      data = await res.json();

      // Check if Sinatra said "success" inside the try block
      if (!data.success) {
        return fail(401, { message: data.message || "Invalid email or password" });
      }

      // Set the session cookie
      cookies.set('session', data.role, { 
          path: '/', 
          httpOnly: true, 
          sameSite: 'strict',
          maxAge: 60 * 60 * 24 
      });

      // Move redirect out of the catch logic or re-throw it
      throw redirect(303, '/'); 

    } catch (err) {
      // CRITICAL: If the error is a redirect, let it happen!
      if (err.status === 303 || err.status === 302) throw err;

      // Otherwise, it's a real server/network error
      console.error(err);
      return fail(500, { message: "Could not connect to the authentication server." });
    }
  }
};