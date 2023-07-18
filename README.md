## Project Overview (TLDR Edition)

The Cloud Resume Challenge tasks its participants with creating a basic HTML version of their resume and hosting it on AWS using a variety of cloud services, focusing on serverless architecture. That infrastructure should then be converted to code and deployed using a CI/CD pipeline with integrated testing. Here’s a quick run-down of how I interpreted these prompts, and the technologies I used to accomplish each phase of the project:

**Front-End**

- *Portfolio Website*
  - Created using Hugo, a popular static site generator built on Google’s Go language.
  - Hugo Theme – Modified version of Hugo Profile
- *Resume*
  - HTML/CSS version of my resume, with download links to PDF and DOCX versions.
  - View Counter using JavaScript. See next section, “API”
- *S3* – Hosts website, configured with “Public Access.” A second S3 bucket is used to redirect www traffic to the root domain.
- *CloudFront* – Caching, SSL certificate, and HTTP to HTTPS redirection.
- *Route53* – A record aliases for CloudFront, API-Gateway endpoint, and S3 redirection bucket.
  - Domain name, stevenhoward.net, purchased from AWS.
  - Hosted Zone’s Name Servers applied to domain via Terraform.
  
**API**

- *View Counter*, just like those old Geocities / Angelfire pages! All I’m missing is a pixelated, spinning “Under Construction” GIF.
  - *JavaScript* linked at the bottom of the Resume page. On every page load, makes calls to…
  - *API Gateway* (with Cross Origin Resource Sharing headers), linked to…
  - *Lambda* function written in Python (boto3), which reads, increments, writes, and returns a number stored on a…
  - *DynamoDB* table, stores the view count number.
  
**End-to-End Testing**

- Cypress, a JavaScript testing framework that simulates the loading of a web page and clicking various elements. See “CI/CD” section for more details.

**Infrastructure as Code (IaC)**

- *Terraform*, the industry leader in provisioning infrastructure via code.
  - Deploys all back-end infrastructure, including S3, API Gateway, Lambda, DynamoDB, Route53, Certificate Manager, and CloudFront.
  - State stored in *Terraform Cloud*.

**Continuous Integration / Continuous Deployment (CI/CD)**

- *GitHub Actions*
  - Back-End
    - *Terraform* – Applies all back-end infrastructure.
    - *Cypress* – Tests API reachability.
  - Front-End
    - *Hugo* – Builds static website.
    - *AWS CLI* – Copies website files to S3 bucket.
    - *Cypress* – Tests HTTP return code and BODY content.