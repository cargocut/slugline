> [!WARNING]  
> This project is still **highly experimental**, but we would be
> delighted to receive feedback (but please be careful with
> production).

# slugline

> A very small (and portable)
> [slugifier](https://developer.mozilla.org/en-US/docs/Glossary/Slug)
> implementation.

The implementation is relatively **naïve and opinionated**, but should
be sufficient for most use cases. It has largely been imported from
[YOCaml](https://github.com/xhtmlboi/yocaml) (which provides its own
[implementation](https://github.com/xhtmlboi/yocaml/blob/635c3948ee6415e7b9f967a8ad07850757b76256/lib/core/slug.ml))
and is small, with no dependencies, making it easy to use with
[Js_of_ocaml](https://ocsigen.org/js_of_ocaml/latest/manual/overview)
and [Mirage](https://mirage.io/). The implementation attempts to
intelligently merge separators and is fairly configurable. A more
ambitious implementation is provided by the [Slug
package](https://ocaml.org/p/slug/latest).


```ocaml
# "Hello world, this is a slug héhéhé" 
  |> Slugline.from_string
  |> Slugline.to_string ;;
- : string = "hello-world-this-is-a-slug-hehehe"
```
