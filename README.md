# Stream Content API

## Tech Stack

- **Ruby**: 3.2.2
- **Rails**: 8.0.3
- **Database**: PostgreSQL
- **Testing**: RSpec

## Setup

```bash
bundle install
rails db:create db:migrate
rails db:seed
```

## Testing

```bash
bundle exec rspec
```

## Development Process

I decided to divide the development of the task in diferent phases that will be commited and pushed in different branches in order to follow the workflow that I usually use in my projects.
1. **Database-models**: Created the database models and migrations required for the task.
   In this phase I created the models and migrations for Apps, Markets, all content types and its relationships.
   After the first read I'd some hesitations about using STI or Polymorphic associations for the content types, but after reading again the requirements I decided to go with Polymorphic associations as it seems more flexible for future changes and more adjusted to what I would use in a real world project.
   UserFavoriteApp deserves a special mention as it has some complex logic to handle the position attribute, which I tried to implement in a way that is easy to understand and maintain.
   Our UserWatchedProgram model adds a favorites scope, allowiing us to easily retrieve the programs that a given user has watched the most.
