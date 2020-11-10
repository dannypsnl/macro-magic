#lang scribble/manual
@require[@for-label[macro-magic
                    (except-in racket/base
                        expand)]]

@title{macro-magic}
@author{Lîm Tsú-thuàn}

@defmodule[macro-magic]

This project presents how macro work, by using quoted-expression, we can avoid parser part. The idea of macro is simple: a function operating AST. By operating AST, we can create new syntax for certain usage. Here I present two steps method.

@defform[(parse exp)]{
  In this step we have to distinguish macro and other form, then record macro form @code{define-syntax-rule} into environment.
}

You might think why we don't just use one step, we can do that actually, but price is macro must be defined before usage like @bold{C} does. Now, let's take a look at the second step:

@defform[(expand exp)]{
  This step traverses all AST to lookup pattern, if name matched then check pattern matched.
}

@section{hygienic macro}

With these we already can create macro system that a little bit better than @bold{C}, but that's not enough, the problem shows below:

@racketblock[
(define-syntax-rule (swap first second)
  (let ([tmp first])
    (set! first second)
    (set! second tmp)))
]

Without new @code{let}, @code{(swap tmp other)} produces:

@racketblock[
(let ([tmp tmp])
  (set! tmp other)
  (set! other tmp))
]

Which definitely wrong, to fix this, we need to let variable produces by macro and provide by macro argument were different. For example:

@racketblock[
(let ([tmp19231 tmp])
  (set! tmp other)
  (set! other tmp19231))
]

To archieve this, we need new helpers @code{unique-binding} and @code{subst!}.

@defform[(subst! subst exp)]{
  Replace variables in @code{exp} by substitute map(@code{subst})
}

@defform[(unique-binding exp)]{
  Unique all new bindings in @code{exp}
}

Now, when we record macros in @code{parse}, we use @code{unique-binding} to update macro body:

@racketblock[
(hash-set! macro-env name (@macro pat* (unique-binding body)))
]

When we @code{expand} expression, @code{subst!} macro parameter with macro argument, because of previous @code{unique-binding}, name conflict was resolved.

@section{macro without name}

Another problem would show up, in @bold{Racket}, we can see that some language variants even override application, how? The answer is quite simple, because @bold{Racket} provides @code{#%app} in a more fundamental language, then there has no different between the macro at here.
