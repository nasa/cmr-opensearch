# Making changes

Thanks for contributing!

To allow us to incorporate your changes, please use the following process:

1. Fork this repository to your personal account.
2. Create a branch and make your changes.
3. Test the changes locally in your personal fork.
4. Submit a pull request to open a discussion about your proposed changes.
5. The maintainers will talk with you about it and decide to merge or request additional changes.

Below are specific guidelines for contributing to Earthdata Search.
For general tips on open source contributions, see [Contributing to Open Source on GitHub](https://guides.github.com/activities/contributing-to-open-source/).

# General contribution guidelines

## Be consistent

Please ensure that source code, file structure, and visual design
do not break existing conventions without compelling reasons.

## Test and don't break tests

Add tests for new work to ensure changes work and that future changes
do not break them. Run the test suite to ensure that new changes have
not broken existing features. Ensure that tests pass regardless
of timing or execution order.

We use [Rspec](http://rspec.info/) and [cucumber](https://github.com/cucumber/cucumber-rails) for our tests. We have structured our tests
so that they can describe our system behavior in a meaningful way.
For all the integration tests, please try to form meaningful sentences 
when reading a path of `describe`, `context`, and `it`. For example:

    describe "OpenSearch keyword collection search request" do
      …
      context "for consumers providing a valid GET request and keyword" do
        it "returns an atom feed XML document containing entries for matching collections" { … }
      end
      context "for consumers providing an invalid search parameter name for the GET request" do
        it "returns the appropriate HTTP status code" { … }
        it "returns an XML document with the error details" { … }
      end
    end

Consider the sentences produced by the above:

  1. OpenSearch keyword collection search request for consumers providing a valid GET request and keyword .
  2. OpenSearch keyword collection search request for consumers providing an invalid search parameter name for the GET request returns the appropriate HTTP status code.
  3. OpenSearch keyword collection search request for consumers providing an invalid search parameter name for the GET request returns an XML document with the error details.

The above sentences describe the behavior of the system given varying inputs in a way that is
readable to non-developers.

## Keep tests fast

Our full test suite comprising Rspec and cucumber runs in about 3 minutes due to mocking CMR service calls by using the [VCR](https://github.com/vcr/vcr) gem.

Please test thoroughly and ensure that new tests do not adversely affect the overall performance of the test suite.

# Code structure

Our code follows Ruby on Rails conventions. Please adhere to them when adding new code.

# Dependencies

CMR OpenSearch is implemented primarily using Ruby on Rails 4 running on
Ruby 2 (MRI).

Production instances run on unicorn / nginx and interact with the public [Common Metadata Repository (CMR)](https://cmr.earthdata.nasa.gov/search/) APIs.

See public/licenses.txt for a comprehensive list of dependencies.

# Testing

Fast and consistent tests are critical. The full suite should run in under 2
minutes and faster is better. Please ensure tests run quickly and pass
consistently regardless of execution order.

The [Rspec](http://rspec.info/) tests for the CMR OpenSearch may be run using the `rspec` command. 
The [cucumber](https://github.com/cucumber/cucumber-rails) tests for the CMR OpenSearch may be run using the `cucumber` command.

# License

CMR OpenSearch is licensed under an Apache 2.0 license as described in
the LICENSE file at the root of the project:

> Copyright © 2007-2014 United States Government as represented by the Administrator of the National Aeronautics and Space Administration. All Rights Reserved.
>
> Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.
> You may obtain a copy of the License at
>
>     http://www.apache.org/licenses/LICENSE-2.0
>
> Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS,
> WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

By submitting a pull request, you are agreeing to allow distribution
of your work under the above copyright and license.
