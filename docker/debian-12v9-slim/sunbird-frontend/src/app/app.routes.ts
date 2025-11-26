import { Routes } from '@angular/router';
import { HomeComponent } from './pages/home/home.component';
import { NotFoundComponent } from './pages/not-found/not-found.component';
import { ContactComponent } from './pages/contact/contact.component';
import { ProjectsComponent } from './pages/projects/projects.component';
import { FormsComponent } from './pages/forms/forms.component';
import { FormEditorComponent } from './pages/form-editor/form-editor.component';
import { BlankPageComponent } from './pages/blank-page/blank-page.component';
import { FormPreviewPageComponent } from './pages/form-preview-page/form-preview-page.component';

export const routes: Routes = [
    { path: 'forms', component: FormsComponent, children: [
        { path: 'form/:key', component: FormPreviewPageComponent },
        { path: '', pathMatch: 'full', component: BlankPageComponent },        
        { path: '**', component: NotFoundComponent }
    ] },
    { path: 'form-editor', component: FormEditorComponent, title: 'Form Editor' },
    { path: 'contact', component: ContactComponent, title: 'Contact Us' },
    { path: 'projects', component: ProjectsComponent },
    { path: '', component: HomeComponent, title: 'Home' },
    { path: '**', component: NotFoundComponent, title: 'Not found' }
];
