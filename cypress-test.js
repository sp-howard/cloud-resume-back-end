describe('API response body is not null', () => {
    it('API GET', () => {
        cy.request('GET', 'https://api.stevenhoward.net/viewcount')
        .then((res) => {
          console.log(res)
          expect(res.body).to.not.be.null
        })        
    })
  })
  
  describe('API response status is 200 (OK)', () => {
    it('API GET', () => {
        cy.request('GET', 'https://api.stevenhoward.net/viewcount')
        .then((res) => {
          console.log(res)
          expect(res).to.have.property('status', 200)
        })        
    })
  })
  
  describe('HTML body element exists', () => {
    it('HTML BODY', () => {
        cy.visit('https://stevenhoward.net/')
        cy.get('body')
            .should('exist')
    })
  })