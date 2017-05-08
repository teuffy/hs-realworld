# `hs-realworld`

An implementation of the [RealWorld][realworld] backend in [Haskell][haskell]/[Servant][servant]

Work in progress!

## Overview

This is an incremental implementation of a RealWorld backend using the [incremental API takeover][incremental-api-takeover] approach described by [Matt Parsons][matt-parsons]. This lets us start with a fully functional RealWorld application and then incrementally reimplement it in Haskell/Servant on a route-by-route basis. I have chosen to use the following backend and frontend implementations for this experiment:

* Backend: [Node/Express][node-express-backend]
* Frontend: [React/Redux][react-redux-frontend]

## Getting started

This repo includes private forks of the Node/Express backend and React/Redux frontend as Git submodules. Clone this repo as follows:

```
git clone --recurse-submodules git@github.com:rcook/hs-realworld.git
```

Build with [Stack][haskell-stack]:

```
stack build
```

## Licence

Released under [MIT License][licence]

Copyright &copy; 2017 Richard Cook

[haskell]: https://www.haskell.org/
[haskell-stack]: https://docs.haskellstack.org/en/stable/README/
[incremental-api-takeover]: http://www.parsonsmatt.org/2016/06/24/take_over_an_api_with_servant.html
[licence]: LICENSE
[matt-parsons]: http://www.parsonsmatt.org/
[node-express-backend]: https://github.com/rcook/node-express-realworld-example-app
[react-redux-frontend]: https://github.com/rcook/react-redux-realworld-example-app
[realworld]: https://realworld.io/
[servant]: https://hackage.haskell.org/package/servant
