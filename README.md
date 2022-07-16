# [Common Metadata Repository (CMR) OpenSearch](https://cmr.earthdata.nasa.gov/opensearch)

Visit NASA's EOSDIS CMR OpenSearch at:
[https://cmr.earthdata.nasa.gov/opensearch](https://cmr.earthdata.nasa.gov/opensearch)

The CMR OpenSearch documentation page is at:
[https://cmr.earthdata.nasa.gov/opensearch/home/docs](https://cmr.earthdata.nasa.gov/opensearch/home/docs)

[![Build Status](https://travis-ci.org/nasa/cmr-opensearch.svg?branch=master)](https://travis-ci.org/nasa/cmr-opensearch)

## About
CMR OpenSearch is a web application developed by [NASA](http://nasa.gov) [EOSDIS](https://earthdata.nasa.gov)
to enable data discovery, search, and access across Earth Science data holdings by using an open standard.
It provides an interface compliant with the [OpenSearch 1.1 (Draft 5) specification](https://www.opensearch.org/Home)
by taking advantage of NASA's [Common Metadata Repository (CMR)](https://cmr.earthdata.nasa.gov/search/) APIs for data discovery and access.

## License

> Copyright © 2007-2022 United States Government as represented by the Administrator of the National Aeronautics and Space Administration. All Rights Reserved.
>
> Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.
> You may obtain a copy of the License at
>
>    http://www.apache.org/licenses/LICENSE-2.0
>
> Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS,
> WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

## Third-Party Licenses

See public/licenses.txt

## Installation

* Ruby 2.7.4
* A Ruby version manager such as [RVM](https://rvm.io/) or [rbenv](https://github.com/rbenv/rbenv) is strongly recommended.

### Initial setup
Once the repository is cloned locally and Ruby 2.5.3 is installed, you must install the dependencies.
If you don't have the [bundler](https://bundler.io/) gem already installed, execute the command below in the project root directory:

    gem install bundler   

or if you wish to install the bundler without documentation:

    gem install bundler --no-rdoc --no-ri

Install all the gem dependencies:

    bundle install    

In some cases, depending on your operating system type and/or version, the above command will fail while trying to install
the libv8 and therubyracer gems.  While there might be lots of causes for the errors and lots of
solutions to fix the errors, we found that on some versions of OS X, you can overcome the problem by trying to use the existing
operating system version of the libv8 library, rather than trying to build a new one during the normal gem install.
We found the following workarounds to the _**bundle install**_ failures due to libv8:

    $ brew install v8@3.15
    $ bundle config build.libv8 --with-system-v8
    $ bundle config build.therubyracer --with-v8-dir=$(brew --prefix v8@3.15)
    $ bundle install

Local problems with mimemagic on MACOSX?

    $ brew install shared-mime-info

### Set up the required environment
The application requires the environment variables below to be set in order to run the web application:  

URL of the internal / back-end CMR API instance endpoint.  In a hosted environment, the application
takes advantage of the direct access back-end internal URLs for increased performance in comparison to
the public CMR API instance endpoint. For local installs or installs in non-CMR hosting environments,
the _catalog_rest_endpoint_ and the _public_catalog_rest_endpoint_ should both point to the public
CMR search API endpoint.

    catalog_rest_endpoint = <internal endpoint for the CMR Search API instance used by the application>

URL of your specific CMR OpenSearch install:

    opensearch_url = <CMR OpenSearch application URL>

URL of your specific GraphQL install:

    GRAPHQL_ENDPOINT = <GraphQL application URL>

URL of the public CMR search API instance used in OpenSearch results links in the response ATOM feed:

    public_catalog_rest_endpoint = <public endpoint for the CMR Search API instance>

URL for the release page of the CMR OpenSearch application.
The release page references appear on the user interface as well as in the search results:

    release_page = <CMR OpenSearch EarthData release page>

The ATOM feed author email to be used for CMR entries in the matching ATOM results feed:

    contact = <atom feed author email for each feed entry>

The environment specific postfix (such as dev,PT, TB etc.) for the internally generated client_id sent to echo in
order to obtain an echo token:

    mode = <postfix for client_id string used in obtaining echo tokens>

The ECHO REST endpoint used for obtaining user access tokens:

    echo_rest_endpoint = <echo REST endpoint>

A CMR token with CMR collection tagging permissions in the respective CMR environment that the
_public_catalog_rest_endpoint_ points to:

    CMR_ECHO_SYSTEM_TOKEN = <value>

URL for the CMR documentation page which appears in the OpenSearch web application footer:

    documentation_page = <CMR documentation page URL>

Email for the NASA official responsible for the CMR OpenSearch application:

    organization_contact_email = <email>

Full name for the NASA official responsible for CMR OpenSearch application:

    organization_contact_name = <full name>

We provide default values for the above environment variables to enable running of the automated tests during
CI (continuous integrations) builds.
The application first looks for the configuration file:

    config/application.yml

If the file exists, the application loads the values of variables in the file in the Rails environment.  Having
a local _config/application.yml_ file is an effective way to populate the environment variables
that the application needs in order to run.  A sample _config/application.yml_ file is below:

    current: &current
        opensearch_url: http://localhost:3000/opensearch
        catalog_rest_endpoint: https://cmr.earthdata.nasa.gov/search/
        echo_rest_endpoint: https://api.echo.nasa.gov/echo-rest/
        contact: echodev@echo.nasa.gov
        mode: dev
        public_catalog_rest_endpoint: https://cmr.earthdata.nasa.gov/search/
        release_page: https://wiki.earthdata.nasa.gov/display/echo/Open+Search+API+release+information
        documentation_page: https://wiki.earthdata.nasa.gov/display/CMR/Common+Metadata+Repository+Home
        organization: Sample Organization Name
        organization_contact_email: contact@example.com
        organization_contact_name: ContactFirstName ContactLastName

    development:
        <<: *current
        CMR_ECHO_SYSTEM_TOKEN: "CMR system token with tagging permissions in the CMR environment that development uses"

    production:
        <<: *current
        CMR_ECHO_SYSTEM_TOKEN: "CMR system token with tagging permissions in the CMR PROD environment"

    test: &test
        # test values are already defaulted to enable CI automated Rspec and cucumber tests

### Run the automated [Rspec](http://rspec.info/) and [cucumber](https://github.com/cucumber/cucumber-rails) tests
Execute the commands below in the project root directory:

    bundle exec rspec
    bundle exec cucumber

All tests should pass in less than 2 minutes.

### Run the application
Execute the command below in the project root directory:

    rails server

Open `http://localhost:3000/opensearch` in a local browser.
