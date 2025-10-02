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
2. **API Endpoints**: In this phase I created the API endpoints required for the task.
   Starting with the index and show endpoints for all content types, including the filtering by country and type.
   To serve this pourpose I added a CatalogEntry model that serves as a central point to query all content types, and the Contentable concern will be responsible for registering all content types, providing common functionality and creating the catalog entry after creation.

   For the show endpoint (especially for ChannelProgram) I added a conditional to include the time_watched attribute only when the user_identifier param is provided, as it makes sense to show this information only when we know which user is making the request.
   You will notice that we do not have a User model, this is because the requirements did not specify the need for user authentication or management, that seemed a hint that all the user related logic might be already handled outside of this API, so I decided to keep it simple and just use a user_identifier param to identify the user.

   The endpoint for the list of favorite channel programs for the user based on the time watched was quite straightforward, as we can leverage the favorites scope in the UserWatchedProgram model to get the most watched programs for a given user.

   In order to clean up the ContentsController and respect responsibilities, I added a serie of services to handle the queries. It made easier to define the logic to implement the search endpoint, that queries all content types based on the title or year, and for Apps based on the name.

   Finally, the endpoints included in the AppsController to handle the list of favorite apps for the user and the endpoint to favorite an app and set its position were also quite straightforward, leveraging the UserFavoriteApp model to handle the logic.

   