import type { ComponentNameProps } from './ComponentName.types';

/**
 * ComponentName Component
 * 
 * Description of the component's purpose and usage.
 * 
 * @example
 * ```tsx
 * <ComponentName 
 *   title="Example Title"
 *   description="Example description"
 * />
 * ```
 */
export function ComponentName({
    title,
    description,
    className = '',
    children,
}: Readonly<ComponentNameProps>) {
    return (
        <div className={`p-4 rounded-card bg-surface ${className}`}>
            {title && (
                <h2 className="text-xl font-semibold text-gray-900">
                    {title}
                </h2>
            )}
            {description && (
                <p className="mt-2 text-gray-600">
                    {description}
                </p>
            )}
            {children && (
                <div className="mt-4">
                    {children}
                </div>
            )}
        </div>
    );
}

// Default export for convenience
export default ComponentName;
