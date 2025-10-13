import React from 'react'

export default function Login() {
  return (
    <main className="p-4">
      <h1 className="text-xl font-semibold">Sign in</h1>
      <form className="mt-4 max-w-sm">
        <label className="block">
          <span className="text-sm">Email</span>
          <input className="mt-1 block w-full rounded border p-2" type="email" />
        </label>

        <label className="block mt-3">
          <span className="text-sm">Password</span>
          <input className="mt-1 block w-full rounded border p-2" type="password" />
        </label>

        <button className="mt-4 inline-block rounded bg-blue-600 px-4 py-2 text-white">Sign in</button>
      </form>
    </main>
  )
}
