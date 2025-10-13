import React from 'react'

type Props = React.PropsWithChildren<{ className?: string }>

export default function Button({ children, className = '' }: Props) {
  return (
    <button className={`rounded bg-blue-600 px-3 py-1 text-white ${className}`}>{children}</button>
  )
}
