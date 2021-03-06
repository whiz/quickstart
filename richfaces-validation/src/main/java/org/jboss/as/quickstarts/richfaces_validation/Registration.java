package org.jboss.as.quickstarts.richfaces_validation;

import java.io.Serializable;
import java.util.logging.Logger;

import javax.enterprise.context.SessionScoped;
import javax.enterprise.inject.Produces;
import javax.faces.application.FacesMessage;
import javax.faces.context.FacesContext;
import javax.faces.context.Flash;
import javax.inject.Inject;
import javax.inject.Named;

/**
 * <p>
 * Registration bean holds the new member entity and exposes it to view layer.
 * </p>
 * 
 * <p>
 * It contains JSF-specific logic for handling view transition.
 * </p>
 * 
 * @author Lukas Fryc
 */
@SuppressWarnings("serial")
@SessionScoped
@Named
public class Registration implements Serializable {

    @Inject
    private Logger logger;

    private Member member = new Member();

    /**
     * Exposes new member entity to the other beans and view layer.
     */
    @Produces
    @NewMember
    @Named
    public Member getNewMember() {
        return member;
    }

    /**
     * <p>
     * This method should invoke persistence layer, but in this sample it only logs a successful registration.
     * </p>
     * 
     * <p>
     * Then it contains JSF-specific code which adds a message about successful registration.
     * </p>
     * 
     * <p>
     * Messages are then saved to the flash scope to survive between redirect.
     * </p>
     * 
     * <p>
     * At the end, an outcome is provided to ensure redirection to index page.
     * </p>
     */
    public String proceed() {
        FacesContext facesContext = FacesContext.getCurrentInstance();
        Flash flash = facesContext.getExternalContext().getFlash();

        // save the member to the database
        // e.g.: entityManager.persist(member);

        logger.info("registered member '" + member.getEmail() + "'");

        // add message
        facesContext.addMessage("registrationWizard", new FacesMessage("Hello " + member.getName()
                + ", you have been successfully registered"));

        // tell JSF to keep message to next request (using flash-scope)
        flash.setKeepMessages(true);

        // reset the member registration data
        member = new Member();

        // redirect to index page
        return "index?faces-redirect=true";
    }
}
