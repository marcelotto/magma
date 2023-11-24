---
magma_type: Config.Artefact
tags: [magma-config]
---
# ModuleDoc artefact config

## System prompt

Your task is to generate a project README using the following template (without the surrounding Markdown block), replacing the content between {{ ... }} accordingly:

```markdown
[![Hex.pm](https://img.shields.io/hexpm/v/{{Hex package name}}.svg?style=flat-square)](https://hex.pm/packages/{{Hex package name}})
[![Hex Docs](https://img.shields.io/badge/hex-docs-lightgreen.svg)](https://hexdocs.pm/{{Hex package name}}/)
[![Total Download](https://img.shields.io/hexpm/dt/{{Hex package name}}.svg)](https://hex.pm/packages/{{Hex package name}})
[![License](https://img.shields.io/hexpm/l/{{Hex package name}}.svg)]({{Repo URL}}/blob/main/LICENSE.md)



<br />
<div align="center">
  <a href="{{Homepage URL or Repo URL}}">
    <img src="{{Logo path}}" alt="Logo" width="80" height="80">
  </a>

<h3 align="center">{{Project name}}</h3>

  <p align="center">
    {{A project slogan or description of the project with just a few words}}
    <br />
    <a href="{{Documentation URL}}"><strong>Explore the docs »</strong></a>
    <br />
    <br />
    <a href="{{Demo URL}}">View Demo</a>
    ·
    <a href="{{Repo URL}}/blob/main/CHANGELOG.md">Changelog</a>
    ·
    <a href="{{Repo URL}}/issues">Report Bug</a>
    ·
    <a href="{{Repo URL}}/issues">Request Feature</a>
  </p>
</div>



## About the Project

<img src="{{Screenshot path}}" align="center" />

{{A summary of the project}} 



## Getting Started

### Prerequisites

{{Prerequisites of the project}}


### Installation

{{Step-by-step instructions on installing and setting the project.}}



## Usage

{{Useful examples of how the project can be used.}}

_For more examples, please refer to the [Documentation]({{Documentation URL}})_



## Roadmap

{{Roadmap as a Markdown task list}}

See the [open issues]({{Repo URL}}/issues) for a full list of proposed features (and known issues).



## Contributing

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

If you have a suggestion that would make this better, please fork the repo and create a pull request.
See [CONTRIBUTING](CONTRIBUTING.md) for details.
You can also simply open an issue with the tag "enhancement".

Don't forget to give the project a star! Thanks!



## Contact

{{Contact}}



## Acknowledgments

{{Acknowledgments}}



## License

Distributed under the {{License}}. See `LICENSE.md` for more information.
```


## Task prompt

Generate a README for project '<%= subject.name %>' according to its description and the following information:

- Hex package name: <%= Magma.Matter.Project.app_name() %>
- Repo URL: https://github.com/github_username/repo_name
- Documentation URL: https://hexdocs.pm/<%= Magma.Matter.Project.app_name() %>/
- Homepage URL:
- Demo URL:
- Logo path: logo.jpg
- Screenshot path:
- License: MIT License
- Contact: Your Name - [@twitter_handle](https://twitter.com/twitter_handle) - your@email.com
- Acknowledgments:

("n/a" means not applicable and should result in a removal of the respective parts)
