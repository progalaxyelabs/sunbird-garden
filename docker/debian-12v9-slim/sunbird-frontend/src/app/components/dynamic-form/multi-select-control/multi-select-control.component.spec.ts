import { ComponentFixture, TestBed } from '@angular/core/testing';

import { MultiSelectControlComponent } from './multi-select-control.component';

describe('MultiSelectControlComponent', () => {
  let component: MultiSelectControlComponent;
  let fixture: ComponentFixture<MultiSelectControlComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [MultiSelectControlComponent]
    })
    .compileComponents();

    fixture = TestBed.createComponent(MultiSelectControlComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
