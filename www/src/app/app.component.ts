import { Component, ElementRef, inject, OnInit, RendererFactory2, ViewChild } from '@angular/core';
import { RouterLink, RouterOutlet } from '@angular/router';
import { UpperCasePipe } from '@angular/common';
import { AuthService } from './services/auth.service';
import { BsModalRef, BsModalService, ModalOptions } from 'ngx-bootstrap/modal';
import { BsDropdownDirective, BsDropdownMenuDirective, BsDropdownToggleDirective } from 'ngx-bootstrap/dropdown';
import { SelectWebsiteModalComponent } from './components/select-website-modal/select-website-modal.component';
import { environment } from '../environments/environment';

declare const google: any; // Declare the google object

@Component({
    selector: 'app-root',
    templateUrl: './app.component.html',
    styleUrls: ['./app.component.css'],
    imports: [RouterOutlet, RouterLink, UpperCasePipe, BsDropdownDirective, BsDropdownMenuDirective, BsDropdownToggleDirective]
})
export class AppComponent implements OnInit {
    title = 'Web Meteor'
    isMenuCollapsed = true

    @ViewChild('signinDropdown')
    signinDropdown!: ElementRef

    signinStatus = false
    googleSigninButtonRendered = false

    bsModalRef?: BsModalRef;

    constructor(
        private auth: AuthService,
        private modalService: BsModalService
    ) {
        this.auth.status.subscribe((value: boolean) => {
            this.signinStatus = value
            console.log('in listener: signin status changed to ' + (value ? 'true' : 'false'))
        })
    }

    private async initGoogleSignin() {
        await this.googleLibLoaded()
        google.accounts.id.initialize({
            client_id: '108864518050-fjhjlifc56klj8rsmm4r9tmn9p7j632d.apps.googleusercontent.com',
            callback: this.handleCredentialResponse.bind(this),
            auto_select: false,
            auto_prompt: false,
            cancel_on_tap_outside: true,
        });

        console.log('google signin initialized')
    }

    private async googleLibLoaded(): Promise<void> {
        return new Promise((resolve, reject) => {
            const intervalTime = 50
            let timeElapsed = 0
            const intervalHandler = setInterval(() => {
                if ('google' in window) {
                    clearInterval(intervalHandler)
                    console.log(`gogole signin library loaded in ${timeElapsed}ms`)
                    resolve()
                } else {
                    timeElapsed += intervalTime
                    console.log(`waiting for google signin library to load ${timeElapsed}ms`)
                }
            }, intervalTime)
        })
    }

    async ngOnInit(): Promise<void> {
        await this.initGoogleSignin()
        console.log('on init')
    }

    handleCredentialResponse(response: any): void {
        console.log('Encoded JWT ID token: ' + response.credential);
        // Send token to backend for verification
        this.verifyToken(response.credential);
    }

    verifyToken(token: string): void {
        fetch(`${environment.apiUrl}/auth/google-signin`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ googleToken: token }),
        })
            .then((response) => {
                if (!response.ok) {
                    throw new Error(`HTTP error! status: ${response.status}`);
                }
                return response.json();
            })
            .then((data) => {
                console.log('Backend verification response:', data);
                // Only set authenticated status if backend verification succeeds
                if (data.data && data.data.token) {
                    localStorage.setItem('authToken', data.data.token);
                    this.auth.setUserData(data.data.user);
                    this.auth.status.next(true);
                } else {
                    throw new Error('Invalid response from server');
                }
            })
            .catch((error) => {
                console.error('Error verifying token:', error);
                this.auth.status.next(false);
                // Optionally show error to user
                alert('Sign in failed. Please try again.');
            });
    }

    signOut() {
        google.accounts.id.disableAutoSelect();
        this.googleSigninButtonRendered = false;
        this.auth.status.next(false);
        this.auth.clearUserData();
        localStorage.removeItem('authToken');
        console.log('User signed out');
    }

    onDropdownShown() {
        console.log('dropdown shown, element ',)

        if (this.googleSigninButtonRendered) {
            console.log('google signin button already rendered')
            return
        }

        setTimeout(() => {
            const signinButtonContainer = document.getElementById('signin-button-container')
            if (!signinButtonContainer) {
                console.error('signin button container not found to render google signin button')
                return
            }

            const app = this

            google.accounts.id.renderButton(
                signinButtonContainer,
                {
                    theme: "outline",
                    size: "large",
                    click_listener: () => (app.signinDropdown as any).hide()
                }
            );
            this.googleSigninButtonRendered = true
        }, 50)
    }

    openWebsiteSelectionDialog(e: Event) {
        const initialState: ModalOptions = {
            initialState: {
              list: ['Open a modal with component', 'Pass your data', 'Do something else', '...'],
              title: 'Modal with component'
            }
          };
          this.bsModalRef = this.modalService.show(SelectWebsiteModalComponent, initialState);
          this.bsModalRef.content.closeBtnName = 'Close';
    }

}
