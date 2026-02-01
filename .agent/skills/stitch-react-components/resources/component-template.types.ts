import type { ReactNode } from 'react';

/**
 * Props for the ComponentName component
 * 
 * All props should be readonly to ensure immutability
 */
export interface ComponentNameProps {
    /**
     * Main title text
     */
    readonly title?: string;

    /**
     * Description or subtitle text
     */
    readonly description?: string;

    /**
     * Additional CSS classes to apply
     */
    readonly className?: string;

    /**
     * Child elements to render
     */
    readonly children?: ReactNode;
}
