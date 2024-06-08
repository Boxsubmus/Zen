# Zen
Ideas for a programming language

## About
Zen is a statically and strongly typed object-oriented programming language that is also subset of C. It is designed as a language for game development first, and therefore, most of it's decisions come from that perspective.

Zen is an opinionated-language. While Rust focuses on *safety*, Zen focuses on *correctness*. The name is a play on the fact that you're *zen* when you know that your code is "correct".

## What does 'correctness' mean?

The common assertion that you may hear a lot is: "Make it work, make it right, make it fast". In almost every language, making it right is *optional*, and when it's optional, it often means it's never done.

Correctness, in the context of Zen, means 'making it right is **mandatory**'.

Behaviors included but not limited to which are considered "incorrect":

* Leaks of memory or other resources
* Deadlocks
* Exiting without calling destructors
* Integer overflow
* Returning a stack-allocated object
* Freeing without nullifying
* Writing to a pointer created from an immutable reference
* Implicit casting floats to ints
* Undefined behavior

An example of the compiler enforcing correctness:

```cs
public fun void draw()
{
    // Immutable variable, we don't expect this to change and we will throw an error if it ever does. 
    let pos = Vector2(32, 32);

    {
        // Mutable variable, we expect this to change and we will throw an error if it doesn't.
        var scale = Vector2(1, 1);

        Graphics::DrawRectangle(pos, scale, Color::Orange);
    } // Scope ends, error thrown for 'scale' because it is incorrect that a variable was marked as mutable, yet it was not treated as such.

} // Scope ends, no error for 'pos' because we respect the fact that it's immutable
```