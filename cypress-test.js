describe('Response body is not null', () => {
    it('API GET', () => {
        cy.request('GET', 'https://jo5mk3uvbj.execute-api.us-west-1.amazonaws.com/viewcount')
        .then((res) => {
          console.log(res)
          expect(res.body).to.not.be.null
        })        
    })
  })
  
  describe('Response status is 200', () => {
    it('API GET', () => {
        cy.request('GET', 'https://jo5mk3uvbj.execute-api.us-west-1.amazonaws.com/viewcount')
        .then((res) => {
          console.log(res)
          expect(res).to.have.property('status', 200)
        })        
    })
  })
  
  describe('Body element exists', () => {
    it('HTML BODY', () => {
        cy.visit('https://stevenhoward.net/')
        cy.get('body')
            .should('exist')
    })
  })